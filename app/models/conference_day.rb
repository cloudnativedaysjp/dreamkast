class ConferenceDay < ApplicationRecord
  has_many :talks, -> {order('conference_day_id ASC, start_time ASC')}
end
