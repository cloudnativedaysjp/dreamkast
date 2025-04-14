# == Schema Information
#
# Table name: form_values
#
#  id           :bigint           not null, primary key
#  value        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  form_item_id :bigint           not null
#  profile_id   :bigint           not null
#
# Indexes
#
#  index_form_values_on_form_item_id  (form_item_id)
#  index_form_values_on_profile_id    (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (form_item_id => form_items.id)
#  fk_rails_...  (profile_id => profiles.id)
#
FactoryBot.define do
  factory :form_value do
    association :profile
    association :form_item
    value { 'テストの回答内容' }
  end
end
