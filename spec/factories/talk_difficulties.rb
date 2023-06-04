# == Schema Information
#
# Table name: talk_difficulties
#
#  id            :bigint           not null, primary key
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer
#
# Indexes
#
#  index_talk_difficulties_on_conference_id  (conference_id)
#

FactoryBot.define do
  factory :talk_difficulties1, class: TalkDifficulty do
    id { 1 }
    name { 'Beginner - 初級者' }
    conference_id { 1 }
  end
  factory :cndo_talk_difficulties1, class: TalkDifficulty do
    id { 10 }
    name { 'Beginner - 初級者' }
    conference_id { 2 }
  end
end
