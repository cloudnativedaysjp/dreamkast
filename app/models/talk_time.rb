# == Schema Information
#
# Table name: talk_times
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  time_minutes  :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_talk_times_on_conference_id  (conference_id)
#

class TalkTime < ApplicationRecord
  has_many :talks
  belongs_to :conference
end
