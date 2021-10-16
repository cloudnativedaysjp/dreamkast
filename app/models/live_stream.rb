class LiveStream < ApplicationRecord
  belongs_to :conference
  belongs_to :track
end
