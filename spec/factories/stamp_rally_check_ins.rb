# == Schema Information
#
# Table name: stamp_rally_check_ins
#
#  id                         :string(26)       not null, primary key
#  stamp_rally_check_point_id :string(26)       not null
#  profile_id                 :integer          not null
#  check_in_timestamp         :datetime         not null
#
# Indexes
#
#  index_stamp_rally_check_ins_on_profile_id                  (profile_id)
#  index_stamp_rally_check_ins_on_stamp_rally_check_point_id  (stamp_rally_check_point_id)
#

FactoryBot.define do
  factory :stamp_rally_check_in, class: StampRallyCheckIn do
  end
end
