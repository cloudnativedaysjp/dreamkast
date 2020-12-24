class Conference < ApplicationRecord
  enum status: { registered: 0, opened: 1, closed: 2 }

  has_many :form_items
  has_many :conference_days
  has_many :talks
  has_many :tracks
  has_many :sponsors
  has_many :sponsor_types
  has_many :booths
  has_many :links
  has_many :talk_times
end
