# == Schema Information
#
# Table name: media_package_origin_endpoints
#
#  id                       :bigint           not null, primary key
#  endpoint_id              :string(255)
#  media_package_channel_id :bigint           not null
#  streaming_id             :string(255)
#
# Indexes
#
#  index_media_package_origin_endpoints_on_media_package_channel_id  (media_package_channel_id)
#  index_media_package_origin_endpoints_on_streaming_id              (streaming_id)
#
# Foreign Keys
#
#  fk_rails_...  (media_package_channel_id => media_package_channels.id)
#  fk_rails_...  (streaming_id => streamings.id)
#
FactoryBot.define do
  factory :media_package_origin_endpoint
end
