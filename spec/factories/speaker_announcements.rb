FactoryBot.define do
  factory :speaker_announcement do
    conference_id { 4 }
    speaker_names { "mike" }
    publish_time { Time.now }
    body { "test" }
    publish { false }
    trait :published do
      publish { true }
    end
    trait :cndt2020 do
      conference_id { 1 }
      publish { false }
      trait :published do
        publish { true }
      end
    end
  end
end
