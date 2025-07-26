# == Schema Information
#
# Table name: media_package_v2_origin_endpoints
#
#  id                          :string(255)      not null, primary key
#  streaming_id                :string(255)      not null
#  media_package_v2_channel_id :string(255)
#  name                        :string(255)
#
# Indexes
#
#  index_media_package_v2_origin_endpoints_on_name          (name) UNIQUE
#  index_media_package_v2_origin_endpoints_on_streaming_id  (streaming_id)
#  index_origin_endpoints_on_channel_id                     (media_package_v2_channel_id)
#

FactoryBot.define do
  factory :media_package_v2_origin_endpoint, class: MediaPackageV2OriginEndpoint
end
