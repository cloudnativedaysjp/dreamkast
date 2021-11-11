FactoryBot.define do
  factory :talk_category1, class: TalkCategory do
    id { 1 }
    name { "category 1" }
    conference_id { 1 }
  end
  factory :cndo_talk_category1, class: TalkCategory do
    id { 10 }
    name { "category 1" }
    conference_id { 2 }
  end
end
