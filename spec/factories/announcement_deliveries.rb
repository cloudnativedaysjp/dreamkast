FactoryBot.define do
  factory :announcement_delivery do
    association :announcement
    association :profile, factory: :alice
    email { profile.email }
    status { 'queued' }
  end
end
