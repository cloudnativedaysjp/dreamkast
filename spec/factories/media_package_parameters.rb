# == Schema Information
#
# Table name: media_package_parameters
#
#  id                       :string(255)      not null, primary key
#  streaming_id             :string(255)      not null
#  media_package_channel_id :integer          not null
#  name                     :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_media_package_parameters_on_media_package_channel_id  (media_package_channel_id)
#  index_media_package_parameters_on_streaming_id              (streaming_id)
#

FactoryBot.define do
  factory :media_package_parameter
end
