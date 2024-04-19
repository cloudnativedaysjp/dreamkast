# == Schema Information
#
# Table name: media_package_channels
#
#  id           :bigint           not null, primary key
#  channel_id   :string(255)      default("")
#  streaming_id :string(255)
#
# Indexes
#
#  index_media_package_channels_on_channel_id    (channel_id)
#  index_media_package_channels_on_streaming_id  (streaming_id)
#
# Foreign Keys
#
#  fk_rails_...  (streaming_id => streamings.id)
#
FactoryBot.define do
  factory :media_package_channel
end
