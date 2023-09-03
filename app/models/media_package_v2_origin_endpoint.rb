# == Schema Information
#
# Table name: media_package_v2_origin_endpoints
#
#  id                          :string(255)      not null, primary key
#  name                        :string(255)
#  conference_id               :bigint           not null
#  media_package_v2_channel_id :string(255)
#  streaming_id                :string(255)      not null
#  track_id                    :bigint           not null
#
# Indexes
#
#  index_media_package_v2_origin_endpoints_on_conference_id  (conference_id)
#  index_media_package_v2_origin_endpoints_on_name           (name) UNIQUE
#  index_media_package_v2_origin_endpoints_on_streaming_id   (streaming_id)
#  index_media_package_v2_origin_endpoints_on_track_id       (track_id)
#  index_origin_endpoints_on_channel_id                      (media_package_v2_channel_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (streaming_id => streamings.id)
#  fk_rails_...  (track_id => tracks.id)
#

require 'aws-sdk-mediapackagev2'

class MediaPackageV2OriginEndpoint < ApplicationRecord
  include EnvHelper
  include MediaPackageV2Helper

  before_create :set_uuid

  belongs_to :conference
  belongs_to :track
  belongs_to :channel, class_name: 'MediaPackageV2Channel', foreign_key: :media_package_v2_channel_id

  def create_aws_resource
    unless exists_aws_resource?
      resp = media_package_v2_client.create_origin_endpoint(
        {
          channel_group_name:,
          channel_name:,
          origin_endpoint_name:,
          container_type: 'TS',
          segment: {
            segment_duration_seconds: 1,
            segment_name: 'segment',
            ts_use_audio_rendition_group: false,
            include_iframe_only_streams: false,
            ts_include_dvb_subtitles: false
          },
          startover_window_seconds: 60,
          low_latency_hls_manifests: [
            {
              manifest_name: 'll-hls-index',
              manifest_window_seconds: 30,
              program_date_time_interval_seconds: 1
            }
          ]
        }
      )
      media_package_v2_client.put_origin_endpoint_policy(
        {
          channel_group_name:,
          channel_name:,
          origin_endpoint_name:,
          policy: <<~EOS
            {
              "Version": "2012-10-17",
              "Statement": [
                {
                  "Sid": "AllowUser",
                  "Effect": "Allow",
                  "Principal": "*",
                  "Action": "mediapackagev2:GetObject",
                  "Resource": "arn:aws:mediapackagev2:us-east-1:607167088920:channelGroup/#{channel_group_name}/channel/#{channel_name}/originEndpoint/#{origin_endpoint_name}"
                }
              ]
            }
          EOS
        }
      )
      update!(name: resp.origin_endpoint_name)
    end
  rescue => e
    logger.error(e.message)
    delete_aws_resource
  end

  def exists_aws_resource?
    media_package_v2_client.get_origin_endpoint(channel_group_name:, channel_name:, origin_endpoint_name:)
    true
  rescue Aws::MediaPackageV2::Errors::NotFoundException
    false
  rescue => e
    logger.error(e.message)
    false
  end

  def delete_aws_resource
    media_package_v2_client.delete_origin_endpoint_policy(channel_group_name:, channel_name:, origin_endpoint_name:)
    media_package_v2_client.delete_origin_endpoint(channel_group_name:, channel_name:, origin_endpoint_name:)
    loop do
      break unless exists_aws_resource?
    end
    update!(name: '')
  rescue => e
    logger.error(e.message.to_s)
  end

  def aws_resource
    @aws_resource = media_package_v2_client.get_origin_endpoint(channel_group_name:, channel_name:, origin_endpoint_name:)
  end

  def playback_url
    aws_resource&.low_latency_hls_manifests.first.url
  end
end
