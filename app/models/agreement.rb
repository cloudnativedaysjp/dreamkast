class Agreement < ApplicationRecord
  belongs_to :profile
  belongs_to :form_item
end
