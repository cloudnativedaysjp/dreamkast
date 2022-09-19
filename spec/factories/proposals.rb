# == Schema Information
#
# Table name: proposals
#
#  id            :bigint           not null, primary key
#  status        :integer          default("registered"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer          not null
#  talk_id       :integer          not null
#

FactoryBot.define do
  factory :proposal, class: Proposal do
    trait :with_cndt2021 do
      conference_id { 1 }
      status { 0 }
    end
  end
end
