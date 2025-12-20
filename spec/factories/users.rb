FactoryBot.define do
  factory :user do
    sequence(:sub) { |n| "user_#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
  end

  factory :user_alice, class: User do
    sub { 'google-oauth2|alice' }
    email { 'alice@example.com' }

    initialize_with { User.find_or_create_by(sub: 'google-oauth2|alice') { |user| user.email = 'alice@example.com' } }
  end

  factory :user_bob, class: User do
    sub { 'google-oauth2|bob' }
    email { 'bob@example.com' }

    initialize_with { User.find_or_create_by(sub: 'google-oauth2|bob') { |user| user.email = 'bob@example.com' } }
  end
end
