class Talk < ApplicationRecord
  belongs_to :talk_category
  belongs_to :talk_difficulty

  has_many :talks_speakers
  has_many :speakers, through: :talks_speakers
end
