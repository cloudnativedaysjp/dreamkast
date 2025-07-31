class TalkTime < ApplicationRecord
  has_many :talks
  belongs_to :conference
end
