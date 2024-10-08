# == Schema Information
#
# Table name: check_in_conferences
#
#  id                 :bigint           not null, primary key
#  check_in_timestamp :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  conference_id      :bigint           not null
#  profile_id         :bigint           not null
#  scanner_profile_id :bigint
#
# Indexes
#
#  index_check_in_conferences_on_conference_id  (conference_id)
#  index_check_in_conferences_on_profile_id     (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (profile_id => profiles.id)
#
class CheckInConference < ApplicationRecord
  belongs_to :conference
  belongs_to :profile
  belongs_to :scanner_profile, optional: true, class_name: 'Profile'
end
