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

class FormValue < ApplicationRecord
  belongs_to :profile
  belongs_to :form_item

  validates :profile_id, uniqueness: { scope: :form_item_id, message: 'は既にこのフォーム項目に回答しています' }
  validates :value, allow_blank: true, length: { maximum: 1000 }
end
