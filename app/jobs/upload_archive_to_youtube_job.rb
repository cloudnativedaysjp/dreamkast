require 'aws-sdk-s3'

class UploadArchiveToYoutubeJob < ApplicationJob
  include YoutubeHelper
  include MediaConvertHelper

  self.queue_adapter = :async unless Rails.env.test?

  # MediaConvert ジョブの完了待ちのポーリング設定
  POLL_INTERVAL = 15 # seconds
  POLL_TIMEOUT = 60 * 60 # 1 hour

  def perform(video)
    @video = video

    # 冪等性: 既にアップロード済みならスキップ（強制再実行は status を戻してから）
    return if @video.youtube_available?

    @video.update!(youtube_upload_status: :converting, youtube_upload_error: nil)
    mp4_path = convert_hls_to_mp4(@video)

    @video.update!(youtube_upload_status: :uploading)
    youtube_id = upload_to_youtube(@video, mp4_path)

    @video.update!(
      youtube_video_id: youtube_id,
      youtube_upload_status: :uploaded,
      youtube_uploaded_at: Time.current
    )
  rescue => e
    @video&.update!(youtube_upload_status: :failed, youtube_upload_error: e.message)
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  ensure
    cleanup_tmp_files(@video) if @video
  end

  # アーカイブ HLS を MediaConvert で mp4 化し、ローカル一時ファイルにダウンロードしてそのパスを返す
  def convert_hls_to_mp4(video)
    harvest_job = video.talk.media_package_harvest_jobs.order(created_at: :desc).first
    raise '対象 Talk のアーカイブ(HarvestJob)が見つかりません' if harvest_job.nil?

    job_id = create_media_convert_job(
      input_uri: harvest_job.s3_manifest_uri,
      output_uri_prefix: output_uri_prefix(video)
    )
    wait_for_media_convert(job_id)
    download_mp4(video)
  end

  def upload_to_youtube(video, mp4_path)
    snippet = Youtube::MetadataBuilder.new(video.talk).snippet
    upload_video_to_youtube(mp4_path, snippet:)
  end

  def cleanup_tmp_files(video)
    dir = tmp_dir(video)
    FileUtils.rm_rf(dir) if Dir.exist?(dir)
  end

  private

  def wait_for_media_convert(job_id)
    deadline = Time.current + POLL_TIMEOUT
    loop do
      status = media_convert_job_status(job_id)
      case status
      when 'COMPLETE'
        return
      when 'ERROR', 'CANCELED'
        raise "MediaConvert ジョブが失敗しました (status=#{status}, job_id=#{job_id})"
      end
      raise "MediaConvert ジョブがタイムアウトしました (job_id=#{job_id})" if Time.current > deadline

      sleep(POLL_INTERVAL)
    end
  end

  # 出力プレフィックス配下に生成された mp4 をローカルにダウンロードする
  def download_mp4(video)
    bucket = output_bucket
    prefix = output_key_prefix(video)
    obj = s3_client.list_objects_v2(bucket:, prefix:).contents.find { |o| o.key.end_with?('.mp4') }
    raise '変換後の mp4 が出力バケットに見つかりません' if obj.nil?

    FileUtils.mkdir_p(tmp_dir(video))
    local_path = File.join(tmp_dir(video), File.basename(obj.key))
    s3_client.get_object(response_target: local_path, bucket:, key: obj.key)
    local_path
  end

  def output_bucket
    ENV.fetch('YOUTUBE_MP4_BUCKET')
  end

  def output_key_prefix(video)
    "youtube/#{video.talk_id}/"
  end

  def output_uri_prefix(video)
    "s3://#{output_bucket}/#{output_key_prefix(video)}"
  end

  def tmp_dir(video)
    Rails.root.join('tmp', 'youtube_uploads', video.id.to_s).to_s
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
