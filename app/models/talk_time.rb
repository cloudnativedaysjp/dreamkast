# == Schema Information
#
# Table name: talk_times
#
#  id            :bigint           not null, primary key
#  time_minutes  :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#
# Indexes
#
#  index_talk_times_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#

class TalkTime < ApplicationRecord
  has_many :talks
  belongs_to :conference
end
