# == Schema Information
#
# Table name: check_in_talks
#
#  id                 :bigint           not null, primary key
#  check_in_timestamp :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  profile_id         :bigint           not null
#  talk_id            :bigint           not null
#
# Indexes
#
#  index_check_in_talks_on_profile_id  (profile_id)
#  index_check_in_talks_on_talk_id     (talk_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (talk_id => talks.id)
#
class CheckInTalk < ApplicationRecord
  belongs_to :talk
  belongs_to :profile
end
