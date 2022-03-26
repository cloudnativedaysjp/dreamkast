# == Schema Information
#
# Table name: proposals
#
#  id            :integer          not null, primary key
#  talk_id       :integer          not null
#  conference_id :integer          not null
#  status        :integer          default("0"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :proposal, class: Proposal do
    trait :with_cndt2021 do
      conference_id { 1 }
      status { 0 }
    end
  end
end
