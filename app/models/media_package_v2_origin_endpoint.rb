# == Schema Information
#
# Table name: media_package_v2_origin_endpoints
#
#  id                                :bigint           not null, primary key
#  name                              :string(255)
#  conference_id                     :bigint           not null
#  media_package_v2_channel_group_id :bigint           not null
#  media_package_v2_channel_id       :bigint           not null
#  track_id                          :bigint           not null
#
# Indexes
#
#  index_media_package_v2_origin_endpoints_on_conference_id  (conference_id)
#  index_media_package_v2_origin_endpoints_on_name           (name) UNIQUE
#  index_media_package_v2_origin_endpoints_on_track_id       (track_id)
#  index_origin_endpoints_on_channel_group_id                (media_package_v2_channel_group_id)
#  index_origin_endpoints_on_channel_id                      (media_package_v2_channel_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (track_id => tracks.id)
#

require 'aws-sdk-mediapackagev2'

class MediaPackageV2OriginEndpoint < ApplicationRecord
  include EnvHelper

  belongs_to :conference
  belongs_to :track
  belongs_to :media_package_v2_channel

  def ensure_resource
    resp = media_package_v2_client.create_origin_endpoint(
      {
        channel_group_name: get_channel_group_name,
        channel_name: get_channel_name,
        origin_endpoint_name: get_origin_endpoint_name,
        container_type: 'TS',
        segment: {
          segment_duration_seconds: 6,
          segment_name: 'segment',
          ts_use_audio_rendition_group: false,
          include_iframe_only_streams: false,
          ts_include_dvb_subtitles: false
        },
        startover_window_seconds: 900,
        low_latency_hls_manifests: [
          {
            manifest_name: 'll-hls-index',
            manifest_window_seconds: 60,
            program_date_time_interval_seconds: 1
          }
        ]
      }
    )
    resp = media_package_v2_client.put_origin_endpoint_policy(
      {
        channel_group_name: get_channel_group_name,
        channel_name: get_channel_name,
        origin_endpoint_name: get_origin_endpoint_name,
        policy: <<~EOS
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Sid": "AllowUser",
                "Effect": "Allow",
                "Principal": "*",
                "Action": "mediapackagev2:GetObject",
                "Resource": "arn:aws:mediapackagev2:us-east-1:607167088920:channelGroup/#{get_channel_group_name}/channel/#{get_channel_name}/originEndpoint/#{get_origin_endpoint_name}"
              }
            ]
          }
        EOS
      }
    )
    update!(channel_group_name: get_channel_group_name, channel_name: resp.channel_name)
  rescue => e
    logger.error(e.message)
    delete_resource
  end

  def exists?
    media_package_v2_client.describe_origin_endpoint(channel_group_name:, channel_name:, origin_endpoint_name: get_origin_endpoint_name)
    true
  rescue Aws::MediaPackageV2::Errors::NotFoundException
    false
  rescue => e
    logger.error(e.message)
    false
  end

  def delete_resource
    media_package_v2_client.delete_origin_endpoint_policy(channel_group_name:, channel_name:, origin_endpoint_name:)
    media_package_v2_client.delete_origin_endpoint(channel_group_name:, channel_name:, origin_endpoint_name:)
  rescue => e
    logger.error(e.message.to_s)
  end

  private

  def media_package_v2_client
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    @client ||= if creds.set?
                  Aws::MediaPackageV2::Client.new(region: AWS_LIVE_STREAM_REGION, credentials: creds)
                else
                  Aws::MediaPackageV2::Client.new(region: AWS_LIVE_STREAM_REGION)
                end
  end

  def get_channel_group_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end

  def get_channel_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end

  def get_origin_endpoint_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end
end
