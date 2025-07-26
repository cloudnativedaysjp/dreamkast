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

FactoryBot.define do
  factory :talk_time do
    conference { nil }
    time_minutes { '' }
  end
end
