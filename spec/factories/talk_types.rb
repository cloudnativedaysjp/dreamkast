FactoryBot.define do
  factory :talk_type do
    sequence(:id) { |n| "type_#{n}" }
    sequence(:display_name) { |n| "Type #{n}" }
    description { 'Test talk type' }
    is_exclusive { false }

    trait :session do
      id { 'Session' }
      display_name { '公募セッション' }
      description { '公募セッション' }
      is_exclusive { false }
    end

    trait :keynote do
      id { 'KeynoteSession' }
      display_name { 'キーノート' }
      description { 'メインの基調講演' }
      is_exclusive { false }
    end

    trait :sponsor do
      id { 'SponsorSession' }
      display_name { 'スポンサーセッション' }
      description { 'スポンサー企業によるセッション' }
      is_exclusive { false }
    end

    trait :intermission do
      id { 'Intermission' }
      display_name { '休憩' }
      description { '休憩時間' }
      is_exclusive { true }
    end

    trait :exclusive do
      is_exclusive { true }
    end
  end

  factory :talk_type_association do
    association :talk
    association :talk_type
  end
end
