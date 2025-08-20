FactoryBot.define do
  factory :talk_attribute do
    sequence(:name) { |n| "attribute_#{n}" }
    sequence(:display_name) { |n| "Attribute #{n}" }
    description { 'Test talk attribute' }
    is_exclusive { false }

    trait :keynote do
      name { 'keynote' }
      display_name { 'キーノート' }
      description { 'メインの基調講演' }
      is_exclusive { false }
    end

    trait :sponsor do
      name { 'sponsor' }
      display_name { 'スポンサーセッション' }
      description { 'スポンサー企業によるセッション' }
      is_exclusive { false }
    end

    trait :intermission do
      name { 'intermission' }
      display_name { '休憩' }
      description { '休憩時間' }
      is_exclusive { true }
    end

    trait :exclusive do
      is_exclusive { true }
    end
  end

  factory :talk_attribute_association do
    association :talk
    association :talk_attribute
  end
end
