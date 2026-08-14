require 'aws-sdk-mediaconvert'

module MediaConvertHelper
  # AWS MediaConvert クライアント。認証情報の扱いは MediaPackageHelper と同じ流儀。
  def media_convert_client
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    options = { region: AWS_LIVE_STREAM_REGION }
    options[:credentials] = creds if creds.set?
    # アカウント固有のエンドポイントが ENV にあれば利用（無ければ SDK が解決）
    options[:endpoint] = ENV['MEDIACONVERT_ENDPOINT'] if ENV['MEDIACONVERT_ENDPOINT'].present?
    Aws::MediaConvert::Client.new(options)
  end

  # HLS(.m3u8) を入力に mp4(H.264/AAC, faststart) を出力する MediaConvert ジョブを作成し、job id を返す。
  # input_uri: 's3://bucket/key.m3u8'、output_uri_prefix: 's3://bucket/path/'（末尾スラッシュ）
  def create_media_convert_job(input_uri:, output_uri_prefix:)
    resp = media_convert_client.create_job(
      role: ENV.fetch('MEDIACONVERT_ROLE_ARN'),
      settings: {
        inputs: [{ file_input: input_uri }],
        output_groups: [{
          output_group_settings: {
            type: 'FILE_GROUP_SETTINGS',
            file_group_settings: { destination: output_uri_prefix }
          },
          outputs: [{
            container_settings: {
              container: 'MP4',
              mp4_settings: { free_space_box: 'EXCLUDE', moov_placement: 'PROGRESSIVE_DOWNLOAD' }
            },
            video_description: {
              codec_settings: {
                codec: 'H_264',
                h264_settings: { rate_control_mode: 'QVBR', max_bitrate: 5_000_000 }
              }
            },
            audio_descriptions: [{
              codec_settings: {
                codec: 'AAC',
                aac_settings: { bitrate: 128_000, coding_mode: 'CODING_MODE_2_0', sample_rate: 48_000 }
              }
            }]
          }]
        }]
      }
    )
    resp.job.id
  end

  def media_convert_job_status(job_id)
    media_convert_client.get_job(id: job_id).job.status
  end
end
