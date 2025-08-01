require 'aws-sdk-mediapackagev2'

class MediaPackageV2ChannelGroup < ApplicationRecord
  include EnvHelper
  include MediaPackageV2Helper

  before_create :set_uuid
  before_destroy :delete_aws_resource

  belongs_to :streaming
  has_one :channel, class_name: 'MediaPackageV2Channel'

  def create_aws_resource
    unless exists_aws_resource?
      resp = media_package_v2_client.create_channel_group(channel_group_name:)
      update!(name: resp.channel_group_name)
    end
  end

  def delete_aws_resource
    if exists_aws_resource?
      media_package_v2_client.delete_channel_group(channel_group_name:)
      loop do
        break unless exists_aws_resource?
      end
      update!(name: '')
    end
  end

  def exists_aws_resource?
    media_package_v2_client.get_channel_group(channel_group_name:)
    true
  rescue Aws::MediaPackageV2::Errors::NotFoundException
    false
  rescue => e
    logger.error(e.message)
    false
  end
end
