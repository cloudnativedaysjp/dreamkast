class FormValue < ApplicationRecord
  belongs_to :profile
  belongs_to :form_item

  validates :profile_id, uniqueness: { scope: :form_item_id, message: 'は既にこのフォーム項目に回答しています' }
  validates :value, allow_blank: true, length: { maximum: 1000 }
end
