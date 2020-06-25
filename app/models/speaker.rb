class Speaker < ApplicationRecord
  has_many :talks_speakers
  has_many :talks, through: :talks_speakers
end
