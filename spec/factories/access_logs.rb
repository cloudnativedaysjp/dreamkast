# == Schema Information
#
# Table name: access_logs
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  sub        :string(255)
#  page       :string(255)
#  ip         :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :integer
#

FactoryBot.define do
  factory :access_log, class: AccessLog do
  end
end
