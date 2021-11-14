FactoryBot.define do
  factory :speaker_announcement do
    conference_id { 4 }
    speaker_id { 3 }
    speaker_name { "mike" }
    publish_time { Time.now }
    body { "test" }
    publish { false }
    open { false }
    trait :published do
      publish { true }
    end
  end
end
