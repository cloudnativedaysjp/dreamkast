# == Schema Information
#
# Table name: check_in_stamp_rallies
#
#  id                 :bigint           not null, primary key
#  check_in_timestamp :datetime         not null
#  profile_id         :bigint           not null
#  stamp_rally_def_id :bigint           not null
#
# Indexes
#
#  index_check_in_stamp_rallies_on_profile_id          (profile_id)
#  index_check_in_stamp_rallies_on_stamp_rally_def_id  (stamp_rally_def_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (stamp_rally_def_id => stamp_rally_defs.id)
#
class CheckInStampRally < ApplicationRecord
  belongs_to :profile
  belongs_to :stamp_rally_def
end
