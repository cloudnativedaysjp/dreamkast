# == Schema Information
#
# Table name: stats_of_registrants
#
#  id                    :bigint           not null, primary key
#  number_of_registrants :integer
#  offline_attendees     :decimal(10, )
#  online_attendees      :decimal(10, )
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  conference_id         :bigint
#
# Indexes
#
#  index_stats_of_registrants_on_conference_id  (conference_id)
#
FactoryBot.define do
  factory :stats_of_registrant
end
