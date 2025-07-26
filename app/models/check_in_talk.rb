# == Schema Information
#
# Table name: check_in_talks
#
#  id                 :integer          not null, primary key
#  talk_id            :integer          not null
#  profile_id         :integer          not null
#  check_in_timestamp :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  scanner_profile_id :integer
#
# Indexes
#
#  index_check_in_talks_on_profile_id  (profile_id)
#  index_check_in_talks_on_talk_id     (talk_id)
#

class CheckInTalk < ApplicationRecord
  belongs_to :talk
  belongs_to :profile
  belongs_to :scanner_profile, optional: true, class_name: 'Profile'
end
