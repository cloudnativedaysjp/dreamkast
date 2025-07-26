# == Schema Information
#
# Table name: check_in_conferences
#
#  id                 :integer          not null, primary key
#  conference_id      :integer          not null
#  profile_id         :integer          not null
#  check_in_timestamp :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  scanner_profile_id :integer
#
# Indexes
#
#  index_check_in_conferences_on_conference_id  (conference_id)
#  index_check_in_conferences_on_profile_id     (profile_id)
#

class CheckInConference < ApplicationRecord
  belongs_to :conference
  belongs_to :profile
  belongs_to :scanner_profile, optional: true, class_name: 'Profile'
end
