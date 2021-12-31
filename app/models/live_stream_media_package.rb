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
require 'aws-sdk-mediapackage'

class LiveStreamMediaPackage < LiveStream
  include MediaPackageHelper
  include EnvHelper

  belongs_to :conference
  belongs_to :track

  before_destroy do
    delete_media_package_resources
  rescue => e
    logger.error(e.message)
  end

  def initialize(attributes = nil)
    @params = {}
    super
  end

  def channel
    @channel ||= media_package_client.describe_channel(id: channel_id)
  end

  def channel_id
    params&.dig('channel_id')
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
    channel_id = resp.id

    resp = media_package_client.describe_channel(id: channel_id)
    params = {
      channel_id: resp.id,
      channel_arn: resp.arn
    }
    update!(params: params)
  rescue => e
    logger.error(e.message)
    delete_media_package_resources(channel_id: id)
  end

  def delete_media_package_resources(channel_id: self.channel_id)
    media_package_client.delete_channel(channel_id: channel_id) if channel_id
  rescue => e
    logger.error(e.message.to_s)
  end

  private

  def create_channel_params
    tags = { 'Environment' => env_name }
    tags['ReviewAppNumber'] = review_app_number.to_s if ENV['DREAMKAST_NAMESPACE']
    {
      id: resource_name,
      description: '',
      tags: tags
    }
  end

  def resource_name
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end
end
