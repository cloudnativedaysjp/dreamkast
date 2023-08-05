# == Schema Information
#
# Table name: media_package_v2_channel_groups
#
#  id            :bigint           not null, primary key
#  name          :string(255)
#  conference_id :bigint           not null
#
# Indexes
#
#  index_media_package_v2_channel_groups_on_conference_id  (conference_id)
#  index_media_package_v2_channel_groups_on_name           (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#

require 'aws-sdk-mediapackagev2'

class MediaPackageV2ChannelGroup < ApplicationRecord
  include EnvHelper
  include MediaPackageV2Helper

  belongs_to :conference
  has_many :channels, class_name: 'MediaPackageV2Channel'

  def create_aws_resource
    unless exists_aws_resource?
      resp = media_package_v2_client.create_channel_group(channel_group_name:)
      update!(name: resp.channel_group_name)
    end
  rescue => e
    logger.error(e.message)
    delete_aws_resource
  end

  def delete_aws_resource
    media_package_v2_client.delete_channel_group(channel_group_name:) if exists_aws_resource?
    while true do
      break unless exists_aws_resource?
    end
    update!(name: '')
  rescue => e
    logger.error(e.message.to_s)
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
