# == Schema Information
#
# Table name: media_package_origin_endpoints
#
#  id                       :bigint           not null, primary key
#  conference_id            :bigint           not null
#  endpoint_id              :string(255)
#  media_package_channel_id :bigint           not null
#  streaming_id             :string(255)
#
# Indexes
#
#  index_media_package_origin_endpoints_on_conference_id             (conference_id)
#  index_media_package_origin_endpoints_on_media_package_channel_id  (media_package_channel_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (media_package_channel_id => media_package_channels.id)
#

class MediaPackageOriginEndpoint < ApplicationRecord
  include MediaPackageHelper
  include EnvHelper

  belongs_to :conference
  belongs_to :media_package_channel
  belongs_to :streaming

  def origin_endpoint
    @origin_endpoint ||= media_package_client.describe_origin_endpoint(id: endpoint_id)
  rescue => e
    logger.error(e.message.to_s)
  end

  def create_media_package_resources
    resp = media_package_client.create_origin_endpoint(create_params)
    update!(endpoint_id: resp.id)
  rescue => e
    logger.error(e.message)
    delete_aws_resource
  end

  def delete_aws_resource
    media_package_client.delete_origin_endpoint(id: endpoint_id)
  rescue => e
    logger.error(e.message.to_s)
  end

  private

  def create_params
    {
      id: resource_name,
      channel_id: media_package_channel.channel_id,
      tags:,
      hls_package: {
        ad_markers: 'NONE',
        ad_triggers: ['SPLICE_INSERT', 'PROVIDER_ADVERTISEMENT', 'DISTRIBUTOR_ADVERTISEMENT', 'PROVIDER_PLACEMENT_OPPORTUNITY', 'DISTRIBUTOR_PLACEMENT_OPPORTUNITY'],
        ads_on_delivery_restrictions: 'RESTRICTED',
        include_iframe_only_stream: false,
        playlist_type: 'EVENT',
        playlist_window_seconds: 60,
        program_date_time_interval_seconds: 0,
        segment_duration_seconds: 6,
        stream_selection: {
          max_video_bits_per_second: 2_147_483_647,
          min_video_bits_per_second: 0,
          stream_order: 'ORIGINAL'
        },
        use_audio_rendition_group: false
      },
      manifest_name: 'index',
      origination: 'ALLOW',
      startover_window_seconds: 86400,
      time_delay_seconds: 5
    }
  end

  def tags
    tags = { 'Environment' => env_name }
    tags['ReviewAppNumber'] = review_app_number.to_s if ENV['DREAMKAST_NAMESPACE']
    tags
  end

  def resource_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{media_package_channel.track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{media_package_channel.track.name}"
    end
  end
end
