# == Schema Information
#
# Table name: media_package_v2_channels
#
#  id                                :bigint           not null, primary key
#  name                              :string(255)
#  conference_id                     :bigint           not null
#  media_package_v2_channel_group_id :bigint           not null
#  track_id                          :bigint           not null
#
# Indexes
#
#  index_channels_on_channel_group_id                (media_package_v2_channel_group_id)
#  index_media_package_v2_channels_on_conference_id  (conference_id)
#  index_media_package_v2_channels_on_name           (name) UNIQUE
#  index_media_package_v2_channels_on_track_id       (track_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (track_id => tracks.id)
#

require 'aws-sdk-mediapackagev2'

class MediaPackageV2Channel < ApplicationRecord
  include EnvHelper

  belongs_to :conference
  belongs_to :track
  belongs_to :channel_group, class_name: 'MediaPackageV2ChannelGroup'
  has_one :origin_endpoint, class_name: 'MediaPackageV2OriginEndpoint'

  def create_resource
    unless exists?
      media_package_v2_client.create_channel(channel_group_name: get_channel_group_name, channel_name: get_channel_name)
      # update!(channel_group_name: get_channel_group_name, channel_name: resp.channel_name)
    end
  rescue => e
    logger.error(e.message)
    delete_media_package_resources
  end

  def delete_resource
    media_package_v2_client.delete_channel(id: channel_name) if channel_name.present?
  rescue => e
    logger.error(e.message.to_s)
  end

  def exists?
    media_package_v2_client.get_channel(channel_group_name: name, channel_name: name)
    true
  rescue Aws::MediaPackageV2::Errors::NotFoundException
    false
  rescue => e
    logger.error(e.message)
    false
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
end
