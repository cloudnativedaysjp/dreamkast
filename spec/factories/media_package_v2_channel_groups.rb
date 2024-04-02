# == Schema Information
#
# Table name: media_package_v2_channel_groups
#
#  id           :string(255)      not null, primary key
#  name         :string(255)
#  streaming_id :string(255)      not null
#
# Indexes
#
#  index_media_package_v2_channel_groups_on_name          (name) UNIQUE
#  index_media_package_v2_channel_groups_on_streaming_id  (streaming_id)
#
# Foreign Keys
#
#  fk_rails_...  (streaming_id => streamings.id)
#

FactoryBot.define do
  factory :media_package_v2_channel_group, class: MediaPackageV2ChannelGroup
end
