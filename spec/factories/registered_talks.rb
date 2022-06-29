# == Schema Information
#
# Table name: registered_talks
#
#  id         :integer          not null, primary key
#  profile_id :integer
#  talk_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :registered_talk, class: RegisteredTalk do
  end
end
