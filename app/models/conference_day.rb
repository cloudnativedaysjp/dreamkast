class ConferenceDay < ApplicationRecord
  has_many :talks, -> {order('conference_day_id ASC, HOUR(start_time) ASC, MINUTE(start_time) ASC, track ASC')}
end
