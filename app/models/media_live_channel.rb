# == Schema Information
#
# Table name: media_live_channels
#
#  id                  :string(255)      not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  channel_id          :string(255)
#  media_live_input_id :string(255)      not null
#  streaming_id        :string(255)      not null
#
# Indexes
#
#  index_media_live_channels_on_media_live_input_id  (media_live_input_id)
#  index_media_live_channels_on_streaming_id         (streaming_id)
#
# Foreign Keys
#
#  fk_rails_...  (media_live_input_id => media_live_inputs.id)
#  fk_rails_...  (streaming_id => streamings.id)
#

require 'aws-sdk-medialive'

class MediaLiveChannel < ApplicationRecord
  include MediaLiveHelper
  include SsmHelper
  include EnvHelper

  before_create :set_uuid

  belongs_to :media_live_input
  belongs_to :streaming

  CHANNEL_CREATING = 'CREATING'.freeze
  CHANNEL_CREATE_FAILED = 'CREATE_FAILED'.freeze
  CHANNEL_IDLE = 'IDLE'.freeze
  CHANNEL_STARTING = 'STARTING'.freeze
  CHANNEL_RUNNING = 'RUNNING'.freeze
  CHANNEL_RECOVERING = 'RECOVERING'.freeze
  CHANNEL_STOPPING = 'STOPPING'.freeze
  CHANNEL_DELETING = 'DELETING'.freeze
  CHANNEL_DELETED = 'DELETED'.freeze
  CHANNEL_UPDATING = 'UPDATING'.freeze
  CHANNEL_UPDATE_FAILED = 'UPDATE_FAILED'.freeze
  ERROR = 'ERROR'.freeze

  def create_aws_resource
    unless exists_aws_resource?
      params = create_channel_params(media_live_input.aws_resource.id, media_live_input.aws_resource.name)
      resp = media_live_client.create_channel(params)
      update!(channel_id: resp.channel.id)
      wait_channel_until(:channel_created, resp.channel.id)
    end
  end

  def exists_aws_resource?
    media_live_client.describe_channel(channel_id:)
    true
  rescue Aws::MediaLive::Errors::NotFoundException
    false
  rescue => e
    logger.error(e.message)
    false
  end

  def delete_aws_resource
    if exists_aws_resource?
      media_live_client.delete_channel(channel_id:)
      wait_channel_until(:channel_deleted, channel_id)
    end
  end

  def start_channel
    media_live_client.start_channel(channel_id:)
  end

  def stop_channel
    media_live_client.stop_channel(channel_id:)
  end

  def idle?
    aws_resource && aws_resource.state == CHANNEL_IDLE
  end

  def running?
    aws_resource && aws_resource.state == CHANNEL_RUNNING
  end

  def state
    aws_resource&.state
  end

  def aws_resource
    @aws_resource ||= media_live_client.describe_channel(channel_id:)
  end

  private

  def resource_name
    conference = streaming.conference
    track = streaming.track

    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end

  def tags
    tags = { 'Environment' => env_name }
    tags['ReviewAppNumber'] = review_app_number.to_s if ENV['DREAMKAST_NAMESPACE']
    tags
  end

  def create_channel_params(input_id, input_name)
    params = {
      name: resource_name,
      role_arn: 'arn:aws:iam::607167088920:role/MediaLiveAccessRole',
      channel_class: 'SINGLE_PIPELINE',
      tags:,
      destinations: [],
      input_attachments: [
        {
          input_attachment_name: input_name,
          input_id:,
          input_settings: {
            caption_selectors: [],
            audio_selectors: [{ name: 'Default' }],
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
        audio_descriptions: [],
        caption_descriptions: [],
        output_groups: [],
        timecode_config: {
          source: 'EMBEDDED'
        },
        video_descriptions: []
      }
    }

    if streaming.media_package_channel
      output_group_media_package = OutputGroupMediaPackage.new(resource_name, streaming.media_package_channel.ingest_endpoint_url, streaming.media_package_channel.ingest_endpoint_username,
                                                               streaming.media_package_channel.ingest_endpoint_password)
      params[:destinations] << output_group_media_package.destination
      params[:encoder_settings][:audio_descriptions].concat(output_group_media_package.audio_descriptions)
      params[:encoder_settings][:output_groups] << output_group_media_package.output_group
      params[:encoder_settings][:video_descriptions].concat(output_group_media_package.video_descriptions)
    end

    if streaming.media_package_v2_channel
      output_group_media_package_v2 = OutputGroupMediaPackageV2.new(streaming.media_package_v2_channel.ingest_endpoint_url)
      params[:destinations] << output_group_media_package_v2.destination
      params[:encoder_settings][:audio_descriptions].concat(output_group_media_package_v2.audio_descriptions)
      params[:encoder_settings][:output_groups] << output_group_media_package_v2.output_group
      params[:encoder_settings][:video_descriptions].concat(output_group_media_package_v2.video_descriptions)
    end

    params
  end

  class OutputGroupIvs
    def initialize(ingest_endpoint, stream_key)
      @ingest_endpoint = ingest_endpoint
      @stream_key = stream_key
    end

    def destination
      {
        id: 'dest-ivs',
        media_package_settings: [],
        settings: [
          {
            url: "rtmps://#{@ingest_endpoint}:443/app/",
            stream_name: @stream_key
          }
        ]
      }
    end

    def audio_descriptions
      [
        {
          name: 'audio_al2b0j',
          audio_selector_name: 'Default',
          audio_type_control: 'FOLLOW_INPUT',
          language_code_control: 'FOLLOW_INPUT'
        }
      ]
    end

    def output_group
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
              output_name: 'dest-ivs',
              output_settings: {
                rtmp_output_settings: {
                  certificate_mode: 'VERIFY_AUTHENTICITY',
                  connection_retry_interval: 2,
                  destination: {
                    destination_ref_id: 'dest-ivs'
                  },
                  num_retries: 10
                }
              },
              video_description_name: 'video_ue3og'
            }
          ]
      }
    end

    def video_descriptions
      [
        {
          name: 'video_ue3og',
          respond_to_afd: 'NONE',
          scaling_behavior: 'DEFAULT',
          sharpness: 50
        }
      ]
    end
  end

  class OutputGroupMediaPackage
    def initialize(resource_name, ingest_endpoint_url, ingest_endpoint_username, ingest_endpoint_password)
      @resource_name = resource_name
      @ingest_endpoint_url = ingest_endpoint_url
      @ingest_endpoint_username = ingest_endpoint_username
      @ingest_endpoint_password = ingest_endpoint_password
    end

    def destination
      {
        id: 'dest-mediapackage',
        settings: [
          {
            url: @ingest_endpoint_url,
            username: @ingest_endpoint_username,
            password_param:  "/medialive/#{@resource_name}"
          }
        ]
      }
    end

    def audio_descriptions
      [
        audio_description_template('audio_1', 192000, 48000),
        audio_description_template('audio_2', 192000, 48000),
        audio_description_template('audio_3', 128000, 48000)
      ]
    end

    def audio_description_template(name, bitrate, sample_rate)
      {
        name:,
        audio_selector_name: 'Default',
        audio_type_control: 'FOLLOW_INPUT',
        codec_settings:
          {
            aac_settings:
              {
                bitrate:,
                coding_mode: 'CODING_MODE_2_0',
                input_type: 'NORMAL',
                profile: 'LC',
                rate_control_mode: 'CBR',
                raw_format: 'NONE',
                sample_rate:,
                spec: 'MPEG4'
              }
          },
        language_code_control: 'FOLLOW_INPUT'
      }
    end

    def output_group
      {
        name: 'To MediaPackage',
        output_group_settings: {
          hls_group_settings: {
            ad_markers: [],
            caption_language_mappings: [],
            caption_language_setting: 'OMIT',
            client_cache: 'ENABLED',
            codec_specification: 'RFC_4281',
            destination: { destination_ref_id: 'dest-mediapackage' },
            directory_structure: 'SINGLE_DIRECTORY',
            discontinuity_tags: 'INSERT',
            hls_cdn_settings: {
              hls_webdav_settings: {
                connection_retry_interval: 1,
                filecache_duration: 300,
                http_transfer_mode: 'NON_CHUNKED',
                num_retries: 10,
                restart_delay: 15
              }
            },
            hls_id_3_segment_tagging: 'DISABLED',
            i_frame_only_playlists: 'DISABLED',
            incomplete_segment_behavior: 'AUTO',
            index_n_segments: 10,
            input_loss_action: 'EMIT_OUTPUT',
            iv_in_manifest: 'INCLUDE',
            iv_source: 'FOLLOWS_SEGMENT_NUMBER',
            keep_segments: 21,
            manifest_compression: 'NONE',
            manifest_duration_format: 'INTEGER',
            mode: 'LIVE',
            output_selection: 'MANIFESTS_AND_SEGMENTS',
            program_date_time: 'EXCLUDE',
            program_date_time_period: 600,
            redundant_manifest: 'DISABLED',
            segment_length: 1,
            segmentation_mode: 'USE_SEGMENT_DURATION',
            segments_per_subdirectory: 10000,
            stream_inf_resolution: 'INCLUDE',
            timed_metadata_id_3_frame: 'PRIV',
            timed_metadata_id_3_period: 10,
            ts_file_mode: 'SEGMENTED_FILES'
          }
        },
        outputs: [
          output_template(['audio_1'], '_1080p30', 'video_1080p30'),
          output_template(['audio_2'], '_720p30', 'video_720p30'),
          output_template(['audio_3'], '_480p30', 'video_480p30')
        ]
      }
    end

    def output_template(audio_names, name_modifier, video_description_name)
      {
        audio_description_names: audio_names,
        caption_description_names: [],
        output_settings: {
          hls_output_settings: {
            hls_settings: {
              standard_hls_settings: {
                audio_rendition_sets: 'program_audio',
                m3u_8_settings: {
                  audio_frames_per_pes: 4,
                  audio_pids: '492-498',
                  ecm_pid: '8182',
                  pcr_control: 'PCR_EVERY_PES_PACKET',
                  pmt_pid: '480',
                  program_num: 1,
                  scte_35_behavior: 'NO_PASSTHROUGH',
                  scte_35_pid: '500',
                  timed_metadata_behavior: 'NO_PASSTHROUGH',
                  timed_metadata_pid: '502',
                  video_pid: '481'
                }
              }
            },
            name_modifier:
          }
        },
        video_description_name:
      }
    end

    def video_descriptions
      [
        video_description_template('video_1080p30', 1080, 1920, 5000000, 50),
        video_description_template('video_720p30', 720, 1280, 3000000, 100),
        video_description_template('video_480p30', 480, 854, 1500000, 100)
      ]
    end

    def video_description_template(name, height, width, bitrate, sharpness)
      {
        name:,
        height:,
        width:,
        codec_settings: {
          h264_settings: {
            adaptive_quantization: 'HIGH',
            afd_signaling: 'NONE',
            bitrate:,
            color_metadata: 'INSERT',
            entropy_encoding: 'CABAC',
            flicker_aq: 'ENABLED',
            framerate_control: 'SPECIFIED',
            framerate_denominator: 1,
            framerate_numerator: 30,
            gop_b_reference: 'ENABLED',
            gop_closed_cadence: 1,
            gop_num_b_frames: 1,
            gop_size: 3,
            gop_size_units: 'FRAMES',
            level: 'H264_LEVEL_AUTO',
            look_ahead_rate_control: 'HIGH',
            num_ref_frames: 3,
            par_control: 'INITIALIZE_FROM_SOURCE',
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
        sharpness:
      }
    end
  end

  class OutputGroupMediaPackageV2
    def initialize(ingest_endpoint_url)
      @ingest_endpoint_url = ingest_endpoint_url
    end

    def destination
      {
        id: 'dest-mediapackagev2',
        settings: [
          {
            url: @ingest_endpoint_url
          }
        ]
      }
    end

    def audio_descriptions
      [
        audio_description_template('media_package_v2_audio_1', 192000, 48000),
        audio_description_template('media_package_v2_audio_2', 192000, 48000),
        audio_description_template('media_package_v2_audio_3', 128000, 48000)
      ]
    end

    def audio_description_template(name, bitrate, sample_rate)
      {
        name:,
        audio_selector_name: 'Default',
        audio_type_control: 'FOLLOW_INPUT',
        codec_settings:
          {
            aac_settings:
              {
                bitrate:,
                coding_mode: 'CODING_MODE_2_0',
                input_type: 'NORMAL',
                profile: 'LC',
                rate_control_mode: 'CBR',
                raw_format: 'NONE',
                sample_rate:,
                spec: 'MPEG4'
              }
          },
        language_code_control: 'FOLLOW_INPUT'
      }
    end

    def output_group
      {
        name: 'To MediaPackageV2',
        output_group_settings: {
          hls_group_settings: {
            ad_markers: [],
            caption_language_mappings: [],
            caption_language_setting: 'OMIT',
            client_cache: 'ENABLED',
            codec_specification: 'RFC_4281',
            destination: { destination_ref_id: 'dest-mediapackagev2' },
            directory_structure: 'SINGLE_DIRECTORY',
            discontinuity_tags: 'INSERT',
            hls_cdn_settings: {
              hls_webdav_settings: {
                connection_retry_interval: 1,
                filecache_duration: 300,
                http_transfer_mode: 'NON_CHUNKED',
                num_retries: 10,
                restart_delay: 15
              }
            },
            hls_id_3_segment_tagging: 'DISABLED',
            i_frame_only_playlists: 'DISABLED',
            incomplete_segment_behavior: 'AUTO',
            index_n_segments: 10,
            input_loss_action: 'EMIT_OUTPUT',
            iv_in_manifest: 'INCLUDE',
            iv_source: 'FOLLOWS_SEGMENT_NUMBER',
            keep_segments: 21,
            manifest_compression: 'NONE',
            manifest_duration_format: 'INTEGER',
            mode: 'LIVE',
            output_selection: 'MANIFESTS_AND_SEGMENTS',
            program_date_time: 'EXCLUDE',
            program_date_time_period: 600,
            redundant_manifest: 'DISABLED',
            segment_length: 1,
            segmentation_mode: 'USE_SEGMENT_DURATION',
            segments_per_subdirectory: 10000,
            stream_inf_resolution: 'INCLUDE',
            timed_metadata_id_3_frame: 'PRIV',
            timed_metadata_id_3_period: 10,
            ts_file_mode: 'SEGMENTED_FILES'
          }
        },
        outputs: [
          output_template(['media_package_v2_audio_1'], '_1080p30', 'media_package_v2_video_1080p30'),
          output_template(['media_package_v2_audio_2'], '_720p30', 'media_package_v2_video_720p30'),
          output_template(['media_package_v2_audio_3'], '_480p30', 'media_package_v2_video_480p30')
        ]
      }
    end

    def output_template(audio_names, name_modifier, video_description_name)
      {
        audio_description_names: audio_names,
        caption_description_names: [],
        output_settings: {
          hls_output_settings: {
            hls_settings: {
              standard_hls_settings: {
                audio_rendition_sets: 'program_audio',
                m3u_8_settings: {
                  audio_frames_per_pes: 4,
                  audio_pids: '492-498',
                  ecm_pid: '8182',
                  pcr_control: 'PCR_EVERY_PES_PACKET',
                  pmt_pid: '480',
                  program_num: 1,
                  scte_35_behavior: 'NO_PASSTHROUGH',
                  scte_35_pid: '500',
                  timed_metadata_behavior: 'NO_PASSTHROUGH',
                  timed_metadata_pid: '502',
                  video_pid: '481'
                }
              }
            },
            name_modifier:
          }
        },
        video_description_name:
      }
    end

    def video_descriptions
      [
        video_description_template('media_package_v2_video_1080p30', 1080, 1920, 5000000, 50),
        video_description_template('media_package_v2_video_720p30', 720, 1280, 3000000, 100),
        video_description_template('media_package_v2_video_480p30', 480, 854, 1500000, 100)
      ]
    end

    def video_description_template(name, height, width, bitrate, sharpness)
      {
        name:,
        height:,
        width:,
        codec_settings: {
          h264_settings: {
            adaptive_quantization: 'HIGH',
            afd_signaling: 'NONE',
            bitrate:,
            color_metadata: 'INSERT',
            entropy_encoding: 'CABAC',
            flicker_aq: 'ENABLED',
            framerate_control: 'SPECIFIED',
            framerate_denominator: 1,
            framerate_numerator: 30,
            gop_b_reference: 'ENABLED',
            gop_closed_cadence: 1,
            gop_num_b_frames: 1,
            gop_size: 1,
            gop_size_units: 'SECONDS',
            level: 'H264_LEVEL_AUTO',
            look_ahead_rate_control: 'HIGH',
            num_ref_frames: 3,
            par_control: 'INITIALIZE_FROM_SOURCE',
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
        sharpness:
      }
    end
  end
end
