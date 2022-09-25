# == Schema Information
#
# Table name: registered_talks
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :integer
#  talk_id    :integer
#

FactoryBot.define do
  factory :registered_talk, class: RegisteredTalk
end
