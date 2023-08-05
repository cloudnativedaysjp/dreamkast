# == Schema Information
#
# Table name: media_package_v2_channel_groups
#
#  id            :bigint           not null, primary key
#  name          :string(255)
#  conference_id :bigint           not null
#  track_id      :bigint           not null
#
# Indexes
#
#  index_media_package_v2_channel_groups_on_conference_id  (conference_id)
#  index_media_package_v2_channel_groups_on_name           (name) UNIQUE
#  index_media_package_v2_channel_groups_on_track_id       (track_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (track_id => tracks.id)
#

require 'aws-sdk-mediapackagev2'

class MediaPackageV2ChannelGroup < ApplicationRecord
  include EnvHelper
  include MediaPackageV2Helper

  belongs_to :conference
  belongs_to :track
  has_one :channel, class_name: 'MediaPackageV2Channel'

  def create_aws_resource
    unless exists_aws_resource?
      resp = media_package_v2_client.create_channel_group(channel_group_name: name)
      update!(name: resp.channel_group_name)
    end
  rescue => e
    logger.error(e.message)
    delete_awa_resource
  end

  def delete_aws_resource
    media_package_v2_client.delete_channel_group(channel_group_name: name) if exists_aws_resource?
    update!(name: '')
  rescue => e
    logger.error(e.message.to_s)
  end

  def exists_aws_resource?
    media_package_v2_client.get_channel_group(channel_group_name: name)
    true
  rescue Aws::MediaPackageV2::Errors::NotFoundException
    false
  rescue => e
    logger.error(e.message)
    false
  end
end
