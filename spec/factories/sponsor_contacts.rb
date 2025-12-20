FactoryBot.define do
  factory :sponsor_contact do
    after(:build) do |sponsor_contact|
      next if sponsor_contact.user_id.present?
      next unless sponsor_contact.sub.present? || sponsor_contact.email.present?

      if sponsor_contact.sub.present?
        user = User.find_or_create_by!(sub: sponsor_contact.sub) do |u|
          u.email = sponsor_contact.email || "#{sponsor_contact.sub}@example.com"
        end
        sponsor_contact.user_id = user.id
      elsif sponsor_contact.email.present?
        temp_sub = "temp_#{SecureRandom.hex(8)}"
        user = User.find_or_create_by!(email: sponsor_contact.email) do |u|
          u.sub = temp_sub
        end
        sponsor_contact.user_id = user.id
      end
    end

    before(:create) do |sponsor_contact|
      next if sponsor_contact.user_id.present?
      next unless sponsor_contact.sub.present? || sponsor_contact.email.present?

      if sponsor_contact.sub.present?
        user = User.find_or_create_by!(sub: sponsor_contact.sub) do |u|
          u.email = sponsor_contact.email || "#{sponsor_contact.sub}@example.com"
        end
        sponsor_contact.user_id = user.id
      elsif sponsor_contact.email.present?
        temp_sub = "temp_#{SecureRandom.hex(8)}"
        user = User.find_or_create_by!(email: sponsor_contact.email) do |u|
          u.sub = temp_sub
        end
        sponsor_contact.user_id = user.id
      end
    end
  end

  factory :sponsor_alice, class: SponsorContact do
    sub { 'google-oauth2|alice' }
    email { 'alice@example.com' }
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
      user = User.find_or_create_by!(sub: sponsor_contact.sub) do |u|
        u.email = sponsor_contact.email
      end
      sponsor_contact.user_id = user.id
    end

    before(:create) do |sponsor_contact|
      user = User.find_or_create_by!(sub: sponsor_contact.sub) do |u|
        u.email = sponsor_contact.email
      end
      sponsor_contact.user_id = user.id
    end
  end

  factory :sponsor_bob, class: SponsorContact do
    id { 3 }
    sub { 'bob' }
    email { 'bob@example.com' }
    name { 'bob' }
    conference_id { 1 }

    trait :on_cndt2020 do
      conference_id { 1 }
    end

    trait :on_cndo2021 do
      conference_id { 2 }
    end

    after(:build) do |sponsor_contact|
      user = User.find_or_create_by!(sub: sponsor_contact.sub) do |u|
        u.email = sponsor_contact.email
      end
      sponsor_contact.user_id = user.id
    end

    before(:create) do |sponsor_contact|
      user = User.find_or_create_by!(sub: sponsor_contact.sub) do |u|
        u.email = sponsor_contact.email
      end
      sponsor_contact.user_id = user.id
    end
  end
end
