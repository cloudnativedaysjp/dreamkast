FactoryBot.define do
  factory :speaker_announcement do
    conference_id { 1 }
    publish_time { Time.now }
    body { 'test announcement for alice' }
    publish { false }
    receiver { :person }
    trait :published do
      publish { true }
    end
    trait :published_all do
      body { 'test announcement for all speaker' }
      receiver { :all_speaker }
      publish { true }
    end
    trait :only_accepted do
      body { 'test announcement for only accepted' }
      receiver { :only_accepted }
      publish { true }
    end
    trait :only_rejected do
      body { 'test announcement for only rejected' }
      receiver { :only_rejected }
      publish { true }
    end
    trait :speaker_mike do
      body { 'test announcement for mike' }
      publish { true }
    end
  end
end
