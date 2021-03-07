FactoryBot.define do
  factory :alice, class: Profile do
    id { 1 }
    sub { 'aaa' }
    email { 'foo@example.com' }
    last_name { 'aaa' }
    first_name { 'Alice' }
    industry_id { '1' }
    occupation { 'aaa' }
    company_name { 'aa' }
    company_email { 'bar@example.com' }
    company_address { 'aa' }
    company_tel { '123-4567-8901' }
    department { 'aa' }
    position { 'aaa' }
    conference_id { 1 }
  end

  factory :alice_cndo2021, class: Profile do
    id { 2 }
    sub { 'aaa' }
    email { 'foo@example.com' }
    last_name { 'aaa' }
    first_name { 'Alice' }
    industry_id { '1' }
    occupation { 'aaa' }
    company_name { 'aa' }
    company_email { 'bar@example.com' }
    company_address { 'aa' }
    company_tel { '123-4567-8901' }
    department { 'aa' }
    position { 'aaa' }
    conference_id { 2 }
  end

  factory :bob, class: Profile do
    id { 3 }
    sub { 'bbb' }
    email { 'foo@example.com' }
    last_name { 'bob' }
    first_name { 'Bob' }
    industry_id { '1' }
    occupation { 'aaa' }
    company_name { 'aa' }
    company_email { 'bar@example.com' }
    company_address { 'aa' }
    company_tel { '123-4567-8901' }
    department { 'aa' }
    position { 'aaa' }
    conference_id { 1 }
  end

  factory :bob_cndo2021, class: Profile do
    id { 4 }
    sub { 'bbb' }
    email { 'foo@example.com' }
    last_name { 'bob' }
    first_name { 'Bob' }
    industry_id { '1' }
    occupation { 'aaa' }
    company_name { 'aa' }
    company_email { 'bar@example.com' }
    company_address { 'aa' }
    company_tel { '123-4567-8901' }
    department { 'aa' }
    position { 'aaa' }
    conference_id { 2 }
  end
end