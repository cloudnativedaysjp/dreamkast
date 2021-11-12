FactoryBot.define do
  factory :alice, class: Profile do
    sub { "alice" }
    email { "alice@example.com" }
    last_name { "alice" }
    first_name { "Alice" }
    industry_id { "1" }
    occupation { "aaa" }
    company_name { "aa" }
    company_email { "alice_company@example.com" }
    company_address { "aa" }
    company_tel { "123-4567-8901" }
    department { "aa" }
    position { "aaa" }
    conference_id { 1 }

    trait :on_cndt2020 do
      conference_id { 1 }
    end

    trait :on_cndo2021 do
      conference_id { 2 }
    end
  end

  factory :bob, class: Profile do
    id { 3 }
    sub { "bob" }
    email { "bob@example.com" }
    last_name { "bob" }
    first_name { "Bob" }
    industry_id { "1" }
    occupation { "aaa" }
    company_name { "aa" }
    company_email { "bob_company@example.com" }
    company_address { "aa" }
    company_tel { "123-4567-8901" }
    department { "aa" }
    position { "aaa" }
    conference_id { 1 }

    trait :on_cndt2020 do
      conference_id { 1 }
    end

    trait :on_cndo2021 do
      conference_id { 2 }
    end
  end
end
