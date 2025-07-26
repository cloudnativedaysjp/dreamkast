# == Schema Information
#
# Table name: media_live_channels
#
#  id                  :string(255)      not null, primary key
#  streaming_id        :string(255)      not null
#  media_live_input_id :string(255)      not null
#  channel_id          :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_media_live_channels_on_media_live_input_id  (media_live_input_id)
#  index_media_live_channels_on_streaming_id         (streaming_id)
#

FactoryBot.define do
  factory :media_live_channel
end
