# == Schema Information
#
# Table name: check_ins
#
#  id         :integer          not null, primary key
#  profile_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_check_ins_on_profile_id  (profile_id)
#

FactoryBot.define do
  factory :check_in, class: CheckIn do
  end
end
