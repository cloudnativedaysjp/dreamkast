# == Schema Information
#
# Table name: media_live_inputs
#
#  id                                 :string(255)      not null, primary key
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  input_id                           :string(255)
#  media_live_input_security_group_id :string(255)      not null
#  streaming_id                       :string(255)      not null
#
# Indexes
#
#  index_media_live_inputs_on_media_live_input_security_group_id  (media_live_input_security_group_id)
#  index_media_live_inputs_on_streaming_id                        (streaming_id)
#
# Foreign Keys
#
#  fk_rails_...  (media_live_input_security_group_id => media_live_input_security_groups.id)
#  fk_rails_...  (streaming_id => streamings.id)
#
FactoryBot.define do
  factory :media_live_input
end
