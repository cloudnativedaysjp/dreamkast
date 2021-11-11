FactoryBot.define do
  factory :sponsor do
    id { 1 }
    conference_id { 1 }
    name { "\u30B9\u30DD\u30F3\u30B5\u30FC1\u682A\u5F0F\u4F1A\u793E" }
    abbr { "sponsor1" }
    url { "https://example.com/" }

    trait :with_speaker_emails do
      speaker_emails { "alice@example.com" }
    end
  end
end
