require 'aws-sdk-s3'

module Youtube
  # アーカイブ HLS を MediaConvert で mp4 化し YouTube へアップロードする処理。
  # MediaConvertHelper の完了待ちを 1 回の実行でブロックせず、HarvestJob のポーリングと
  # 同じく状態を DB(youtube_upload_status / media_convert_job_id) に持たせ、定期実行で
  # 「変換開始 → 完了確認 → アップロード」と 1 ステップずつ進める。
  class ArchiveUploader
    include MediaConvertHelper
    include YoutubeHelper

    def initialize(video)
      @video = video
    end

    # 状態を 1 ステップ進める。戻り値:
    # :started(変換開始) / :in_progress(変換中) / :uploaded(完了) / :failed / :skipped
    def process!
      return :skipped unless processable?

      if @video.not_uploaded?
        start_conversion
      elsif @video.converting?
        advance_conversion
      else
        :skipped
      end
    rescue => e
      @video.update!(youtube_upload_status: :failed, youtube_upload_error: e.message)
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace.join("\n"))
      :failed
    end

    private

    def processable?
      @video.video_id.present? && (@video.not_uploaded? || @video.converting?)
    end

    # MediaConvert ジョブを作成し converting に遷移
    def start_conversion
      harvest_job = latest_harvest_job
      raise '対象 Talk のアーカイブ(HarvestJob)が見つかりません' if harvest_job.nil?

      job_id = create_media_convert_job(
        input_uri: harvest_job.s3_manifest_uri,
        output_uri_prefix: output_uri_prefix
      )
      @video.update!(youtube_upload_status: :converting, media_convert_job_id: job_id, youtube_upload_error: nil)
      :started
    end

    # MediaConvert の状態を確認し、完了していればアップロードへ
    def advance_conversion
      case media_convert_job_status(@video.media_convert_job_id)
      when 'COMPLETE'
        upload!
      when 'ERROR', 'CANCELED', nil
        raise "MediaConvert ジョブが失敗しました (job_id=#{@video.media_convert_job_id})"
      else
        :in_progress
      end
    end

    def upload!
      @video.update!(youtube_upload_status: :uploading)
      mp4_path = download_mp4
      youtube_id = upload_video_to_youtube(mp4_path, snippet: Youtube::MetadataBuilder.new(@video.talk).snippet)
      @video.update!(
        youtube_video_id: youtube_id,
        youtube_upload_status: :uploaded,
        youtube_uploaded_at: Time.current
      )
      :uploaded
    ensure
      cleanup_tmp_files
    end

    def latest_harvest_job
      @video.talk.media_package_harvest_jobs.order(created_at: :desc).first
    end

    # 出力プレフィックス配下に生成された mp4 をローカルにダウンロードする
    def download_mp4
      bucket = output_bucket
      obj = s3_client.list_objects_v2(bucket:, prefix: output_key_prefix).contents.find { |o| o.key.end_with?('.mp4') }
      raise '変換後の mp4 が出力バケットに見つかりません' if obj.nil?

      FileUtils.mkdir_p(tmp_dir)
      local_path = File.join(tmp_dir, File.basename(obj.key))
      s3_client.get_object(response_target: local_path, bucket:, key: obj.key)
      local_path
    end

    def cleanup_tmp_files
      FileUtils.rm_rf(tmp_dir) if Dir.exist?(tmp_dir)
    end

    def output_bucket
      ENV.fetch('YOUTUBE_MP4_BUCKET')
    end

    def output_key_prefix
      "youtube/#{@video.talk_id}/"
    end

    def output_uri_prefix
      "s3://#{output_bucket}/#{output_key_prefix}"
    end

    def tmp_dir
      Rails.root.join('tmp', 'youtube_uploads', @video.id.to_s).to_s
    end

    def s3_client
      @s3_client ||= begin
        creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
        options = { region: AWS_LIVE_STREAM_REGION }
        options[:credentials] = creds if creds.set?
        Aws::S3::Client.new(options)
      end
    end
  end
end
