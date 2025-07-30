FactoryBot.define do
  factory :proposal, class: Proposal do
    trait :with_cndt2021 do
      conference_id { 1 }
      status { 0 }
    end

    trait :registered do
      status { 0 }
    end

    trait :accepted do
      status { 1 }
    end

    trait :rejected do
      status { 2 }
    end
  end
end
