class Room < ApplicationRecord
  belongs_to :conference
  has_one :track
end
