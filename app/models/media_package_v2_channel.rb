require 'aws-sdk-mediapackagev2'

class MediaPackageV2Channel < ApplicationRecord
  include EnvHelper
  include MediaPackageV2Helper

  before_create :set_uuid
  before_destroy :delete_aws_resource

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
    if exists_aws_resource?
      media_package_v2_client.delete_channel(channel_group_name:, channel_name:)
      loop do
        break unless exists_aws_resource?
      end
      update!(name: '')
    end
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

  def aws_resource
    @channel ||= media_package_v2_client.get_channel(channel_group_name:, channel_name:)
  end

  def ingest_endpoint_url
    aws_resource.ingest_endpoints[0].url
  end

  private

  def conference
    streaming.conference
  end

  def track
    streaming.track
  end
end
