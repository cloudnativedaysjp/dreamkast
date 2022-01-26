# == Schema Information
#
# Table name: conference_days
#
#  id            :integer          not null, primary key
#  date          :date
#  start_time    :time
#  end_time      :time
#  conference_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  internal      :boolean          default("0"), not null
#
# Indexes
#
#  index_conference_days_on_conference_id  (conference_id)
#

class ConferenceDay < ApplicationRecord
  has_many :talks, -> { order('conference_day_id ASC, HOUR(start_time) ASC, track_id ASC, MINUTE(start_time) ASC') }
  belongs_to :conference

  scope :externals, -> {
    where(internal: false)
  }
end
