# == Schema Information
#
# Table name: media_package_v2_channels
#
#  id                                :string(255)      not null, primary key
#  streaming_id                      :string(255)      not null
#  media_package_v2_channel_group_id :string(255)
#  name                              :string(255)
#
# Indexes
#
#  index_channels_on_channel_group_id               (media_package_v2_channel_group_id)
#  index_media_package_v2_channels_on_name          (name) UNIQUE
#  index_media_package_v2_channels_on_streaming_id  (streaming_id)
#

FactoryBot.define do
  factory :media_package_v2_channel, class: MediaPackageV2Channel
end
