# == Schema Information
#
# Table name: check_ins
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :integer
#
# Indexes
#
#  index_check_ins_on_profile_id  (profile_id)
#
class CheckIn < ApplicationRecord
  has_one :profile
end
