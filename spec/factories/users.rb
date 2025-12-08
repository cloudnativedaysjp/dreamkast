FactoryBot.define do
  factory :user do
    sequence(:sub) { |n| "user_#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
  end
end
