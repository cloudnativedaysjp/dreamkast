FactoryBot.define do
  factory :sponsor do
    id { 1 }
    conference_id { 1 }
    name { 'スポンサー1株式会社' }
    abbr { 'sponsor1' }
    url { 'https://example.com/'}

    trait :with_speaker_emails do
      speaker_emails { 'alice@example.com'}
    end
  end
end
