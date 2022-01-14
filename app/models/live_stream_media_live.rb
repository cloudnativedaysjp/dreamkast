# == Schema Information
#
# Table name: live_streams
#
#  id            :bigint           not null, primary key
#  params        :json
#  type          :string(255)
#  conference_id :bigint           not null
#  track_id      :bigint           not null
#
# Indexes
#
#  index_live_streams_on_conference_id  (conference_id)
#  index_live_streams_on_track_id       (track_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (track_id => tracks.id)
#
require 'aws-sdk-medialive'

class LiveStreamMediaLive < LiveStream
  include MediaLiveHelper
  include EnvHelper

  belongs_to :conference
  belongs_to :track

  before_destroy do
    delete_media_live_resources
  rescue => e
    logger.error(e.message)
  end

  CHANNEL_CREATING = 'CREATING'
  CHANNEL_CREATE_FAILED = 'CREATE_FAILED'
  CHANNEL_IDLE = 'IDLE'
  CHANNEL_STARTING = 'STARTING'
  CHANNEL_RUNNING = 'RUNNING'
  CHANNEL_RECOVERING = 'RECOVERING'
  CHANNEL_STOPPING = 'STOPPING'
  CHANNEL_DELETING = 'DELETING'
  CHANNEL_DELETED = 'DELETED'
  CHANNEL_UPDATING = 'UPDATING'
  CHANNEL_UPDATE_FAILED = 'UPDATE_FAILED'
  ERROR = 'ERROR'

  attr_accessor :channel
  attr_accessor :input

  def initialize(attributes = nil)
    @params = {}
    super
  end

  def get_input_from_aws
    self.input = media_live_client.describe_input(input_id: input_id)
  end

  def get_channel_from_aws
    self.channel = media_live_client.describe_channel(channel_id: channel_id)
  end

  def channel_name
    channel&.name
  end

  def channel_id
    params&.dig('channel_id')
  end

  def channel_state
    channel&.state
  end

  def input_id
    params&.dig('input_id')
  end

  def input_name
    input&.name
  end

  def destination_url
    input ? input.destinations[0].url : ''
  end

  def playback_url
    cloudfront_url = "https://#{cloudfront_domain_name}"
    object_key = destination.gsub("s3://#{bucket_name}/", '')

    "#{cloudfront_url}/#{object_key}.m3u8"
  end

  def destination
    channel&.destinations[0].settings[0].url
  end

  def recording_talk_id
    params&.dig('talk_id')
  end

  def create_media_live_resources
    input_resp = media_live_client.create_input(create_input_params)

    channel_resp = media_live_client.create_channel(create_channel_params(input_resp.input.id, input_resp.input.name))

    wait_until(:channel_created, channel_resp.channel['id'])

    channel_resp = media_live_client.describe_channel(channel_id: channel_resp.channel['id'])
    params = {
      input_id: input_resp.input.id,
      input_arn: input_resp.input.arn,
      channel_id: channel_resp.id,
      channel_arn: channel_resp.arn,
    }
    update!(params: params)
  rescue => e
    logger.error(e.message)
    delete_media_live_resources(input_id: input_resp.input.id, channel_id: channel_resp.channel.id)
  end

  def delete_media_live_resources(input_id: self.input_id, channel_id: self.channel_id)
    media_live_client.delete_channel(channel_id: channel_id) if channel_id
    wait_until(:channel_deleted, channel_id)
    media_live_client.delete_input(input_id: input_id) if input_id
  rescue => e
    logger.error(e.message.to_s)
  end

  def start_channel
    media_live_client.start_channel(channel_id: channel_id)
  end

  def stop_channel
    media_live_client.stop_channel(channel_id: channel_id)
  end

  def set_recording_target_talk(talk_id)
    media_live_client.update_channel(
      {
        channel_id: channel_id,
        destinations: [
          {
            id: 'destination1',
            media_package_settings: [],
            settings: [
              {
                url: "#{destination_base}/talks/#{talk_id}/playlist"
              }
            ]
          }
        ]
      }
    )
    params[:talk_id] = talk_id
    update!(params: params)
  rescue => e
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  end

  private

  def destination_base
    "s3://#{bucket_name}/medialive/#{conference.abbr}"
  end

  def bucket_name
    case env_name
    when 'production'
      'dreamkast-ivs-stream-archive-prd'
    when 'staging'
      'dreamkast-ivs-stream-archive-stg'
    when 'review_app'
      'dreamkast-ivs-stream-archive-dev'
    else
      'dreamkast-ivs-stream-archive-dev'
    end
  end

  def cloudfront_domain_name
    case env_name
    when 'review_app'
      'd1jzp6sbtx9by.cloudfront.net'
    when 'staging'
      'd3i2o0iduabu0p.cloudfront.net'
    when 'production'
      'd3pun3ptcv21q4.cloudfront.net'
    else
      'd1jzp6sbtx9by.cloudfront.net'
    end
  end

  def resource_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end

  def create_input_params
    tags = { 'Environment' => env_name }
    tags['ReviewAppNumber'] = review_app_number.to_s if ENV['DREAMKAST_NAMESPACE']
    {
      name: resource_name,
      type: 'RTMP_PUSH',
      destinations: [
        {
          stream_name: 'aaa/bvbb',
        }
      ],
      input_security_groups: ['8926492'],
      tags: tags
    }
  end

  def create_channel_params(input_id, input_name)
    tags = { 'Environment' => env_name }
    tags['ReviewAppNumber'] = review_app_number.to_s if ENV['DREAMKAST_NAMESPACE']

    {
      name: resource_name,
      role_arn: 'arn:aws:iam::607167088920:role/MediaLiveAccessRole',
      channel_class: 'SINGLE_PIPELINE',
      tags: tags,
      destinations: [
        {
          id: 'dest_ivs',
          settings: [
            {
              url: "rtmps://#{track.live_stream_ivs.ingest_endpoint}:443/app/",
              stream_name: track.live_stream_ivs.stream_key['value']
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
              {
                name: 'Default'
              }
            ],
            deblock_filter: 'DISABLED',
            denoise_filter: 'DISABLED',
            filter_strength: 1,
            input_filter: 'AUTO',
            smpte_2038_data_preference: 'IGNORE',
            source_end_behavior: 'CONTINUE'
          }
        }
      ],

      input_specification: {
        codec: 'AVC',
        maximum_bitrate: 'MAX_20_MBPS',
        resolution: 'HD'
      },

      encoder_settings: {
        audio_descriptions: [
          # For IVS
          {
            name: 'audio_al2b0j',
            audio_selector_name: 'Default',
            audio_type_control: 'FOLLOW_INPUT',
            language_code_control: 'FOLLOW_INPUT'
          }
        ],
        caption_descriptions: [],
        output_groups: [
          output_to_ivs
        ],
        timecode_config: {
          source: 'EMBEDDED'
        },
        video_descriptions: [
          # For IVS
          {
            name: 'video_ue3og',
            respond_to_afd: 'NONE',
            scaling_behavior: 'DEFAULT',
            sharpness: 50
          }
        ]
      }
    }
  end

  def audio_description(name, bitrate, sample_rate)
    {
      name: name,
        audio_selector_name: 'Default',
        audio_type_control: 'FOLLOW_INPUT',
        codec_settings:
          {
            aac_settings:
              {
                bitrate: bitrate,
                coding_mode: 'CODING_MODE_2_0',
                input_type: 'NORMAL',
                profile: 'LC',
                rate_control_mode: 'CBR',
                raw_format: 'NONE',
                sample_rate: sample_rate,
                spec: 'MPEG4'
              }
          },
        language_code_control: 'FOLLOW_INPUT'
    }
  end

  def output_groups
    [
      output_to_ivs
    ]
  end

  def output_to_ivs
    {
      name: 'To IVS',
      output_group_settings:
        {
          rtmp_group_settings:
            {
              ad_markers: [],
              authentication_scheme: 'COMMON',
              cache_full_behavior: 'DISCONNECT_IMMEDIATELY',
              cache_length: 30,
              caption_data: 'ALL',
              input_loss_action: 'EMIT_OUTPUT',
              restart_delay: 15
            }
        },
      outputs:
        [
          {
            audio_description_names: ['audio_al2b0j'],
            caption_description_names: [],
            output_name: 'dest_ivs',
            output_settings: {
              rtmp_output_settings: {
                certificate_mode: 'VERIFY_AUTHENTICITY',
                connection_retry_interval: 2,
                destination: {
                  destination_ref_id: 'dest_ivs'
                },
                num_retries: 10
              }
            },
            video_description_name: 'video_ue3og'
          }
        ]
    }
  end

  def video_description(name, height, width, bitrate, sharpness)
    {
      name: name,
      height: height,
      width: width,
      codec_settings: {
        h264_settings: {
          adaptive_quantization: 'HIGH',
          afd_signaling: 'NONE',
          bitrate: bitrate,
          color_metadata: 'INSERT',
          entropy_encoding: 'CABAC',
          flicker_aq: 'ENABLED',
          framerate_control: 'SPECIFIED',
          framerate_denominator: 1,
          framerate_numerator: 30,
          gop_b_reference: 'ENABLED',
          gop_closed_cadence: 1,
          gop_num_b_frames: 3,
          gop_size: 60,
          gop_size_units: 'FRAMES',
          level: 'H264_LEVEL_AUTO',
          look_ahead_rate_control: 'HIGH',
          num_ref_frames: 3,
          par_control: 'SPECIFIED',
          par_denominator: 3,
          par_numerator: 4,
          profile: 'MAIN',
          rate_control_mode: 'CBR',
          scan_type: 'PROGRESSIVE',
          scene_change_detect: 'ENABLED',
          slices: 1,
          spatial_aq: 'ENABLED',
          syntax: 'DEFAULT',
          temporal_aq: 'ENABLED',
          timecode_insertion: 'DISABLED'
        }
      },
      respond_to_afd: 'NONE',
      scaling_behavior: 'STRETCH_TO_OUTPUT',
      sharpness: sharpness
    }
  end
end
