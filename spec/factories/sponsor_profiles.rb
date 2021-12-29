# == Schema Information
#
# Table name: sponsor_profiles
#
#  id            :bigint           not null, primary key
#  email         :string(255)
#  name          :string(255)
#  sub           :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#  sponsor_id    :bigint           not null
#
# Indexes
#
#  index_sponsor_profiles_on_conference_id  (conference_id)
#  index_sponsor_profiles_on_sponsor_id     (sponsor_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
FactoryBot.define do
  factory :sponsor_alice, class: SponsorProfile do
    sub { 'alice' }
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
  end

  factory :sponsor_bob, class: SponsorProfile do
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
  end
end
