# == Schema Information
#
# Table name: profiles
#
#  id                            :integer          not null, primary key
#  sub                           :string(255)
#  email                         :string(255)
#  last_name                     :string(255)
#  first_name                    :string(255)
#  industry_id                   :integer
#  occupation                    :string(255)
#  company_name                  :string(255)
#  company_email                 :string(255)
#  company_address               :string(255)
#  company_tel                   :string(255)
#  department                    :string(255)
#  position                      :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  conference_id                 :integer
#  company_address_prefecture_id :string(255)
#  first_name_kana               :string(255)
#  last_name_kana                :string(255)
#  company_name_prefix_id        :string(255)
#  company_name_suffix_id        :string(255)
#  company_postal_code           :string(255)
#  company_address_level1        :string(255)
#  company_address_level2        :string(255)
#  company_address_line1         :string(255)
#  company_address_line2         :string(255)
#  number_of_employee_id         :integer          default("12")
#  annual_sales_id               :integer          default("11")
#  company_fax                   :string(255)
#

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

    trait :on_cndt2020 do
      conference_id { 1 }
    end

    trait :on_cndo2021 do
      conference_id { 2 }
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

    trait :on_cndt2020 do
      conference_id { 1 }
    end

    trait :on_cndo2021 do
      conference_id { 2 }
    end
  end

  factory :guest, class: Profile do
    id { 4 }
    sub { 'guest' }
    email { 'guest@cloudnativedays.com' }
    last_name { 'guest' }
    first_name { 'Guest' }
    industry_id { '1' }
    occupation { 'aaa' }
    company_name { 'aa' }
    company_email { 'guest_company@example.com' }
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

    trait :on_cndo2021 do
      conference_id { 2 }
    end
  end
end
