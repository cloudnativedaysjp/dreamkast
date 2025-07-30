class TalkDifficulty < ApplicationRecord
  has_one :talk
  belongs_to :conference
end
