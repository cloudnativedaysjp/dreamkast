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
# Indexes
#
#  index_registered_talks_on_profile_id  (profile_id)
#  index_registered_talks_on_talk_id     (talk_id)
#

FactoryBot.define do
  factory :registered_talk, class: RegisteredTalk
end
