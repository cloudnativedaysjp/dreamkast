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
class FormValue < ApplicationRecord
  belongs_to :profile
  belongs_to :form_item

  validates :profile_id, uniqueness: { scope: :form_item_id, message: 'は既にこのフォーム項目に回答しています' }
  validates :value, presence: true, length: { maximum: 1000 }
end
