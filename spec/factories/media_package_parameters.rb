# == Schema Information
#
# Table name: media_package_parameters
#
#  id                       :string(255)      not null, primary key
#  name                     :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  media_package_channel_id :bigint           not null
#  streaming_id             :string(255)      not null
#
# Indexes
#
#  index_media_package_parameters_on_media_package_channel_id  (media_package_channel_id)
#  index_media_package_parameters_on_streaming_id              (streaming_id)
#
# Foreign Keys
#
#  fk_rails_...  (media_package_channel_id => media_package_channels.id)
#  fk_rails_...  (streaming_id => streamings.id)
#
FactoryBot.define do
  factory :media_package_parameter
end
