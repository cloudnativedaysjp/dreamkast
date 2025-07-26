# == Schema Information
#
# Table name: media_package_origin_endpoints
#
#  id                       :integer          not null, primary key
#  media_package_channel_id :integer          not null
#  endpoint_id              :string(255)
#  streaming_id             :string(255)
#
# Indexes
#
#  index_media_package_origin_endpoints_on_media_package_channel_id  (media_package_channel_id)
#  index_media_package_origin_endpoints_on_streaming_id              (streaming_id)
#

FactoryBot.define do
  factory :media_package_origin_endpoint
end
