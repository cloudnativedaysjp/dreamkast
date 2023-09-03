# == Schema Information
#
# Table name: media_package_channels
#
#  id            :bigint           not null, primary key
#  channel_id    :string(255)      default("")
#  conference_id :bigint           not null
#  track_id      :bigint           not null
#
# Indexes
#
#  index_media_package_channels_on_channel_id     (channel_id)
#  index_media_package_channels_on_conference_id  (conference_id)
#  index_media_package_channels_on_track_id       (track_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (track_id => tracks.id)
#

class MediaPackageChannel < ApplicationRecord
  include MediaPackageHelper
  include EnvHelper

  belongs_to :conference
  belongs_to :track
  has_many :media_package_origin_endpoints
  has_one :media_package_parameter
  has_many :media_package_harvest_jobs

  def channel
    @channel = media_package_client.describe_channel(id: channel_id)
  rescue => e
    logger.error(e.message.to_s)
  end

  def ingest_endpoints
    channel.dig('hls_ingest', 'ingest_endpoints')
  end

  def ingest_endpoint_url
    ingest_endpoints[0]['url']
  end

  def ingest_endpoint_username
    ingest_endpoints[0]['username']
  end

  def ingest_endpoint_password
    ingest_endpoints[0]['password']
  end

  def create_media_package_resources
    resp = media_package_client.create_channel(create_channel_params)
    update!(channel_id: resp.id)
  rescue => e
    logger.error(e.message)
    delete_aws_resource
  end

  def delete_aws_resource
    media_package_client.delete_channel(id: channel_id)
  rescue => e
    logger.error(e.message.to_s)
  end

  private

  def create_channel_params
    {
      id: resource_name,
      description: '',
      tags:
    }
  end

  def tags
    tags = { 'Environment' => env_name }
    tags['ReviewAppNumber'] = review_app_number.to_s if ENV['DREAMKAST_NAMESPACE']
    tags
  end

  def resource_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end
end
