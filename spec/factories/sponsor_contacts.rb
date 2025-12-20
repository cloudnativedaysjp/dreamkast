FactoryBot.define do
  factory :sponsor_contact do
    after(:build) do |sponsor_contact|
      next if sponsor_contact.user_id.present?

      user = FactoryBot.create(:user)
      sponsor_contact.user_id = user.id
    end

    before(:create) do |sponsor_contact|
      next if sponsor_contact.user_id.present?

      user = FactoryBot.create(:user)
      sponsor_contact.user_id = user.id
    end
  end

  factory :sponsor_alice, class: SponsorContact do
    name { 'alice' }
    conference_id { 1 }
    sponsor_id { 1 }

    trait :on_cndt2020 do
      conference_id { 1 }
    end

    trait :on_cndo2021 do
      conference_id { 2 }
    end

    after(:build) do |sponsor_contact|
      next if sponsor_contact.user_id.present?

      user = FactoryBot.create(:user_alice)
      sponsor_contact.user_id = user.id
    end

    before(:create) do |sponsor_contact|
      next if sponsor_contact.user_id.present?

      user = FactoryBot.create(:user_alice)
      sponsor_contact.user_id = user.id
    end
  end

  factory :sponsor_bob, class: SponsorContact do
    id { 3 }
    name { 'bob' }
    conference_id { 1 }

    trait :on_cndt2020 do
      conference_id { 1 }
    end

    trait :on_cndo2021 do
      conference_id { 2 }
    end

    after(:build) do |sponsor_contact|
      next if sponsor_contact.user_id.present?

      user = FactoryBot.create(:user)
      sponsor_contact.user_id = user.id
    end

    before(:create) do |sponsor_contact|
      next if sponsor_contact.user_id.present?

      user = FactoryBot.create(:user)
      sponsor_contact.user_id = user.id
    end
  end
end
