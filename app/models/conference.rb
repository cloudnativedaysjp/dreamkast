class Conference < ApplicationRecord
  has_many :conference_days
  has_many :talks
  has_many :tracks
end
