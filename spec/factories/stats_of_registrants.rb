# == Schema Information
#
# Table name: stats_of_registrants
#
#  id                    :integer          not null, primary key
#  conference_id         :integer
#  number_of_registrants :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  offline_attendees     :decimal(10, )
#  online_attendees      :decimal(10, )
#
# Indexes
#
#  index_stats_of_registrants_on_conference_id  (conference_id)
#

FactoryBot.define do
  factory :stats_of_registrant
end
