# == Schema Information
#
# Table name: check_in_booth_stamp_rallies
#
#  id                        :bigint           not null, primary key
#  check_in_timestamp        :datetime         not null
#  booth_stamp_rally_defs_id :bigint           not null
#  profile_id                :bigint           not null
#
# Indexes
#
#  index_check_in_booth_stamp_rallies_on_booth_stamp_rally_defs_id  (booth_stamp_rally_defs_id)
#  index_check_in_booth_stamp_rallies_on_profile_id                 (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (booth_stamp_rally_defs_id => booth_stamp_rally_defs.id)
#  fk_rails_...  (profile_id => profiles.id)
#
class CheckInBoothStampRally < ApplicationRecord
  belongs_to :profile
  belongs_to :booth_stamp_rally_def
end
