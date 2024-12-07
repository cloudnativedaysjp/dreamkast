# == Schema Information
#
# Table name: profiles
#
#  id                            :bigint           not null, primary key
#  calendar_unique_code          :string(255)
#  company_address               :string(255)
#  company_address_level1        :string(255)
#  company_address_level2        :string(255)
#  company_address_line1         :string(255)
#  company_address_line2         :string(255)
#  company_email                 :string(255)
#  company_fax                   :string(255)
#  company_name                  :string(255)
#  company_postal_code           :string(255)
#  company_tel                   :string(255)
#  department                    :string(255)
#  first_name                    :string(255)
#  first_name_kana               :string(255)
#  last_name                     :string(255)
#  last_name_kana                :string(255)
#  occupation                    :string(255)
#  participation                 :string(255)
#  position                      :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  annual_sales_id               :integer          default(11)
#  company_address_prefecture_id :string(255)
#  company_name_prefix_id        :string(255)
#  company_name_suffix_id        :string(255)
#  conference_id                 :integer
#  industry_id                   :integer
#  number_of_employee_id         :integer          default(12)
#  occupation_id                 :integer          default(34)
#  user_id                       :bigint           not null
#
# Indexes
#
#  index_profiles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :profile

  factory :alice, class: Profile do
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

    after(:build) do |profile, evaluator|
      if evaluator.conference
        profile.conference = evaluator.conference
        profile.user ||= build(:user_alice, conference: evaluator.conference)
      else
        profile.user ||= build(:user_alice)
        profile.conference ||= profile.user.conference
      end
    end
  end

  factory :bob, class: Profile do
    id { 3 }
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

    after(:build) do |profile, evaluator|
      if evaluator.conference
        profile.conference = evaluator.conference
        profile.user ||= build(:user_bob, conference: evaluator.conference)
      else
        profile.user ||= build(:user_bob)
        profile.conference ||= profile.user.conference
      end
    end
  end
end
