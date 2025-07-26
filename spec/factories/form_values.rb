# == Schema Information
#
# Table name: form_values
#
#  id           :integer          not null, primary key
#  profile_id   :integer          not null
#  form_item_id :integer          not null
#  value        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_form_values_on_form_item_id  (form_item_id)
#  index_form_values_on_profile_id    (profile_id)
#

FactoryBot.define do
  factory :form_value do
    association :profile
    association :form_item
    value { 'テストの回答内容' }
  end
end
