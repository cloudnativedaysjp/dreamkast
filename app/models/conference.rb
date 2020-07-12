class Conference < ApplicationRecord
  has_many :form_items
  has_many :conference_days
  has_many :talks
end
