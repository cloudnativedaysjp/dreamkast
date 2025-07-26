# == Schema Information
#
# Table name: media_package_v2_channel_groups
#
#  id           :string(255)      not null, primary key
#  streaming_id :string(255)      not null
#  name         :string(255)
#
# Indexes
#
#  index_media_package_v2_channel_groups_on_name          (name) UNIQUE
#  index_media_package_v2_channel_groups_on_streaming_id  (streaming_id)
#

FactoryBot.define do
  factory :media_package_v2_channel_group, class: MediaPackageV2ChannelGroup
end
