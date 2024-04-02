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

FactoryBot.define do
  factory :media_package_v2_channel, class: MediaPackageV2Channel
end
