FactoryBot.define do
  factory :proposal, class: Proposal do
    trait :with_cndt2021 do
      conference_id { 1 }
      status { 0 }
    end
  end

  factory :proposals_speakers, class: ProposalsSpeaker
end