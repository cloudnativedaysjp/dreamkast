# == Schema Information
#
# Table name: media_package_v2_channels
#
#  id                                :string(255)      not null, primary key
#  name                              :string(255)
#  media_package_v2_channel_group_id :string(255)
#  streaming_id                      :string(255)      not null
#
# Indexes
#
#  index_channels_on_channel_group_id               (media_package_v2_channel_group_id)
#  index_media_package_v2_channels_on_name          (name) UNIQUE
#  index_media_package_v2_channels_on_streaming_id  (streaming_id)
#
# Foreign Keys
#
#  fk_rails_...  (streaming_id => streamings.id)
#

require 'aws-sdk-mediapackagev2'

class MediaPackageV2Channel < ApplicationRecord
  include EnvHelper
  include MediaPackageV2Helper

  before_create :set_uuid

  belongs_to :streaming
  belongs_to :channel_group, class_name: 'MediaPackageV2ChannelGroup', foreign_key: :media_package_v2_channel_group_id
  has_one :origin_endpoint, class_name: 'MediaPackageV2OriginEndpoint'

  def create_aws_resource
    unless exists_aws_resource?
      resp = media_package_v2_client.create_channel(channel_group_name:, channel_name:)
      update!(name: resp.channel_name)
    end
  end

  def delete_aws_resource
    media_package_v2_client.delete_channel(channel_group_name:, channel_name:) if exists_aws_resource?
    loop do
      break unless exists_aws_resource?
    end
    update!(name: '')
  end

  def exists_aws_resource?
    media_package_v2_client.get_channel(channel_group_name:, channel_name:)
    true
  rescue Aws::MediaPackageV2::Errors::NotFoundException
    false
  rescue => e
    logger.error(e.message)
    false
  end

  def channel
    @channel ||= media_package_v2_client.get_channel(channel_group_name:, channel_name:)
  rescue => e
    logger.error(e.message.to_s)
  end

  def ingest_endpoint_url
    channel.ingest_endpoints[0].url
  end

  private

  def conference
    streaming.conference
  end

  def track
    streaming.track
  end
end
