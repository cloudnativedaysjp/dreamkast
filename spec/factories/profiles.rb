FactoryBot.define do
  factory :alice, class: Profile do
    sub { 'alice' }
    email { 'alice@example.com' }
    last_name { 'alice' }
    first_name { 'Alice' }
    industry_id { '1' }
    occupation { 'aaa' }
    company_name { 'aa' }
    company_email { 'alice_company@example.com' }
    company_postal_code { '1010001' }
    company_address_level1 { 'address level 1' }
    company_address_level2 { 'address level 2' }
    company_address_line1 { 'address line 1' }
    company_address_line2 { 'address line 2' }
    company_tel { '12345678901' }
    department { 'aa' }
    position { 'aaa' }
    conference_id { 1 }
    number_of_employee_id { 2 }
    annual_sales_id { 3 }
    participation { 'オンライン参加' }

    trait :on_cndt2020 do
      conference_id { 1 }
      trait :offline do
        participation { 'オフライン参加' }
      end
    end

    trait :on_cndo2021 do
      conference_id { 2 }
    end

    after(:build) do |profile|
      user = User.find_or_create_by!(sub: profile.sub) do |u|
        u.email = profile.email
      end
      profile.user_id = user.id
    end

    before(:create) do |profile|
      user = User.find_or_create_by!(sub: profile.sub) do |u|
        u.email = profile.email
      end
      profile.user_id = user.id
    end
  end

  factory :bob, class: Profile do
    id { 3 }
    sub { 'bob' }
    email { 'bob@example.com' }
    last_name { 'bob' }
    first_name { 'Bob' }
    industry_id { '1' }
    occupation { 'aaa' }
    company_name { 'aa' }
    company_email { 'bob_company@example.com' }
    company_postal_code { '1010001' }
    company_address_level1 { 'address level 1' }
    company_address_level2 { 'address level 2' }
    company_address_line1 { 'address line 1' }
    company_address_line2 { 'address line 2' }
    company_tel { '12345678901' }
    department { 'aa' }
    position { 'aaa' }
    conference_id { 1 }
    number_of_employee_id { 4 }
    annual_sales_id { 5 }
    participation { 'オンライン参加' }

    trait :on_cndt2020 do
      conference_id { 1 }
      trait :offline do
        participation { 'オフライン参加' }
      end
    end

    trait :on_cndo2021 do
      conference_id { 2 }
    end

    after(:build) do |profile|
      user = User.find_or_create_by!(sub: profile.sub) do |u|
        u.email = profile.email
      end
      profile.user_id = user.id
    end

    before(:create) do |profile|
      user = User.find_or_create_by!(sub: profile.sub) do |u|
        u.email = profile.email
      end
      profile.user_id = user.id
    end
  end
end
