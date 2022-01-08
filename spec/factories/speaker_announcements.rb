FactoryBot.define do
  factory :speaker_announcement do
    conference_id { 1 }
    speaker_names { 'alice' }
    publish_time { Time.now }
    body { 'test announcement for alice' }
    publish { false }
    trait :published do
      publish { true }
    end
    trait :speaker_mike do
      speaker_names { 'mike' }
      body { 'test announcement for mike' }
      publish { true }
    end
  end
end
