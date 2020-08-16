class Conference < ApplicationRecord
  has_many :form_items
  has_many :conference_days
  has_many :talks
  has_many :tracks
  has_many :sponsors
  has_many :sponsor_types
  has_many :booths
end
