FactoryBot.define do
  factory :alice, class: Profile do
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
  end
end