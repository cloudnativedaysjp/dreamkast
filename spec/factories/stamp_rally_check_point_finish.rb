# == Schema Information
#
# Table name: stamp_rally_check_ins
#
#  id                          :string(26)       not null, primary key
#  check_in_timestamp          :datetime         not null
#  profile_id                  :bigint           not null
#  stamp_rally_check_points_id :string(26)       not null
#
# Indexes
#
#  index_stamp_rally_check_ins_on_profile_id                   (profile_id)
#  index_stamp_rally_check_ins_on_stamp_rally_check_points_id  (stamp_rally_check_points_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (stamp_rally_check_points_id => stamp_rally_check_points.id)
#

FactoryBot.define do
  factory :stamp_rally_check_point_finish, class: StampRallyCheckPointFinish do
    name { 'スタンプラリーのチェックポイント' }
    description { 'スタンプラリーのチェックポイントの説明' }
  end
end
