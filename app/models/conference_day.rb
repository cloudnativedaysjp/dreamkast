# == Schema Information
#
# Table name: conference_days
#
#  id            :bigint           not null, primary key
#  date          :date
#  end_time      :time
#  internal      :boolean          default(FALSE), not null
#  start_time    :time
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint
#
# Indexes
#
#  index_conference_days_on_conference_id  (conference_id)
#
class ConferenceDay < ApplicationRecord
  has_many :talks, -> { order("conference_day_id ASC, HOUR(start_time) ASC, track_id ASC, MINUTE(start_time) ASC") }

  scope :externals, -> {
    where(internal: false)
  }
end
