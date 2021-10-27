require "aws-sdk-medialive"

class LiveStreamMediaLive < LiveStream
  belongs_to :conference
  belongs_to :track

  before_destroy do
    delete_media_live_resources
  rescue  => e
    logger.error e.message
  end

  def initialize(attributes = nil)
    @params = {}
    super
  end

  def channel_name
    params&.dig('channel', 'name')
  end

  def channel_id
    params&.dig('channel', 'id')
  end

  def input_id
    params&.dig('input', 'id')
  end

  def input_name
    params&.dig('input', 'name')
  end

  def playback_url
    cloudfront_url = "https://#{cloudfront_domain_name}"
    object_key = params&.dig('channel', 'destinations')[0]['settings'][0]['url'].gsub("s3://#{bucket_name}/", '')

    "#{cloudfront_url}/#{object_key}.m3u8"
  end

  def destination
    params&.dig('channel', 'destinations')[0].dig('settings')[0]['url']
  end

  def status
    params&.dig('status')
  end

  def recording_talk_id
    params&.dig('talk_id')
  end

  def create_media_live_resources
    input_resp = media_live_client.create_input(create_input_params)

    channel_resp = media_live_client.create_channel(create_channel_params(input_resp.input.id, input_resp.input.name))

    media_live_client.wait_until(:channel_created, channel_id: channel_resp.channel['id']) do |w|
      w.max_attempts = 60
      w.delay = 10
    end

    params = {
      input: input_resp.input,
      channel: channel_resp.channel
    }
    self.update!(params: params)
  rescue => e
    logger.error e.message
    delete_media_live_resources(input_id: input_resp.input.id, channel_id: channel_resp.channel.id)
  end

  def delete_media_live_resources(input_id: nil, channel_id: nil)
    input_id = self.input_id unless input_id
    channel_id = self.channel_id unless channel_id
    media_live_client.delete_channel(channel_id: channel_id) if channel_id
    media_live_client.wait_until(:channel_deleted, channel_id: channel_id) do |w|
      w.max_attempts = 30
      w.delay = 5
    end

    media_live_client.delete_input(input_id: input_id)if input_id
  rescue => e
    logger.error "#{e.message}"
  end

  def start_recording
    media_live_client.start_channel(channel_id: channel_id)
    media_live_client.wait_until(:channel_running, channel_id: channel_id) do |w|
      w.max_attempts = 60
      w.delay = 10
    end

    params[:status] = 'channel_running'
    self.update!(params: params)
  rescue => e
    logger.error e.message
    logger.error e.backtrace

    params[:status] = 'error'
    params[:error] = e.message
    self.update!(params: params)
  end

  def stop_recording
    media_live_client.stop_channel(channel_id: channel_id)
    media_live_client.wait_until(:channel_stopped, channel_id: channel_id) do |w|
      w.max_attempts = 60
      w.delay = 10
    end

    params[:status] = 'channel_stopped'
    self.update!(params: params)
  rescue => e
    logger.error e.message
    logger.error e.backtrace

    params[:status] = 'error'
    params[:error] = e.message
    self.update!(params: params)
  end

  def set_recording_target_talk(talk_id)
    resp = media_live_client.update_channel(
      {
        channel_id: channel_id,
        destinations: [
          {
            id: "5ari39",
            media_package_settings: [],
            settings: [
              {
                url: "#{destination_base}/talks/#{talk_id}"
              }
            ]
          }
        ]
      }
    )
    params[:channel] = resp.channel
    params[:status] = 'ok'
    params[:talk_id] = talk_id
    self.update!(params: params)
  rescue => e
    logger.error e.message
    logger.error e.backtrace.join("\n")

    params[:status] = 'error'
    params[:error] = e.message
    self.update!(params: params)
  end

  private

  def destination_base
    "s3://#{bucket_name}/medialive/#{conference.abbr}"
  end

  def media_live_client
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    if creds.set?
      Aws::MediaLive::Client.new(region: 'ap-northeast-1', credentials: creds)
    else
      Aws::MediaLive::Client.new(region: 'ap-northeast-1')
    end
  end

  def env_name_for_tag
    case
    when ENV['REVIEW_APP'] == 'true'
      'review_app'
    when ENV['S3_BUCKET'] == 'dreamkast-stg-bucket'
      'staging'
    when ENV['S3_BUCKET'] == 'dreamkast-prd-bucket'
      'production'
    else
      'others'
    end
  end

  def bucket_name
    case env_name_for_tag
    when 'production'
      "dreamkast-ivs-stream-archive-prd"
    when 'staging'
      "dreamkast-ivs-stream-archive-stg"
    when 'review_app'
      "dreamkast-ivs-stream-archive-dev"
    else
      "dreamkast-ivs-stream-archive-dev"
    end
  end

  def cloudfront_domain_name
    case env_name_for_tag
    when 'review_app'
      'd1jzp6sbtx9by.cloudfront.net'
    when 'staging'
      ''
    when 'production'
      ''
    else
      'd1jzp6sbtx9by.cloudfront.net'
    end
  end

  def create_input_params
    {
      name: "#{env_name_for_tag}_#{conference.abbr}_track#{track.name}",
      type: "RTMP_PULL",
      sources: [
        {
          url: track.live_stream_ivs.playback_url
        }
      ]
    }
  end

  def create_channel_params(input_id, input_name)
    {
      name: "#{env_name_for_tag}_#{conference.abbr}_track#{track.name}",
      role_arn: "arn:aws:iam::607167088920:role/MediaLiveAccessRole",
      channel_class: "SINGLE_PIPELINE",
      destinations: [
        {
          id: "5ari39",
          media_package_settings: [],
          settings: [
            {
              url: "s3://#{bucket_name}/medialive/#{conference.abbr}"
            }
          ]
        }
      ],

      input_attachments: [
        {
          input_attachment_name: input_name,
          input_id: input_id,
          input_settings: {
            caption_selectors: [],
            audio_selectors: [
            ],
            deblock_filter: "DISABLED",
            denoise_filter: "DISABLED",
            filter_strength: 1,
            input_filter: "AUTO",
            smpte_2038_data_preference: "IGNORE",
            source_end_behavior: "CONTINUE"
          }
        }
      ],
      input_specification: {
        codec: "AVC",
        maximum_bitrate: "MAX_20_MBPS",
        resolution: "HD"
      },
      encoder_settings: {
        audio_descriptions: [],
        caption_descriptions: [],
        output_groups: [
          {
            name: "test",
            output_group_settings: {
              hls_group_settings: {
                ad_markers: [],
                base_url_content: "",
                base_url_manifest: "",
                caption_language_mappings: [],
                caption_language_setting: "OMIT",
                client_cache: "ENABLED",
                codec_specification: "RFC_4281",
                destination: {
                  destination_ref_id: "5ari39"
                },
                directory_structure: "SINGLE_DIRECTORY",
                discontinuity_tags: "INSERT",
                hls_cdn_settings: {
                  hls_s3_settings: {}
                },
                hls_id_3_segment_tagging: "DISABLED",
                i_frame_only_playlists: "DISABLED",
                incomplete_segment_behavior: "AUTO",
                index_n_segments: 10,
                input_loss_action: "EMIT_OUTPUT",
                iv_in_manifest: "INCLUDE",
                iv_source: "FOLLOWS_SEGMENT_NUMBER",
                keep_segments: 21,
                manifest_compression: "NONE",
                manifest_duration_format: "FLOATING_POINT",
                mode: "LIVE",
                output_selection: "MANIFESTS_AND_SEGMENTS",
                program_date_time: "EXCLUDE",
                program_date_time_period: 600,
                redundant_manifest: "DISABLED",
                segment_length: 10,
                segmentation_mode: "USE_SEGMENT_DURATION",
                segments_per_subdirectory: 10000,
                stream_inf_resolution: "INCLUDE",
                timed_metadata_id_3_frame: "PRIV",
                timed_metadata_id_3_period: 10,
                ts_file_mode: "SEGMENTED_FILES"
              }
            },
            outputs: [
              {
                audio_description_names: [
                  # "audio_4735wd"
                ],
                caption_description_names: [],
                output_name: "g1wlm",
                output_settings: {
                  hls_output_settings: {
                    h265_packaging_type: "HVC1",
                    hls_settings: {
                      standard_hls_settings: {
                        audio_rendition_sets: "program_audio",
                        m3u_8_settings: {
                          audio_frames_per_pes: 4,
                          audio_pids: "492-498",
                          nielsen_id_3_behavior: "NO_PASSTHROUGH",
                          pcr_control: "PCR_EVERY_PES_PACKET",
                          pmt_pid: "480",
                          program_num: 1,
                          scte_35_behavior: "NO_PASSTHROUGH",
                          scte_35_pid: "500",
                          timed_metadata_behavior: "NO_PASSTHROUGH",
                          timed_metadata_pid: "502",
                          video_pid: "481"
                        }
                      }
                    },
                    name_modifier: "_1"
                  }
                },
                video_description_name: "video_rf5ut5"
              }
            ]
          }
        ],
        timecode_config: {
          source: "EMBEDDED"
        },
        video_descriptions: [
          {
            name: "video_rf5ut5",
            respond_to_afd: "NONE",
            scaling_behavior: "DEFAULT",
            sharpness: 50
          }
        ]
      }
    }
  end
end
