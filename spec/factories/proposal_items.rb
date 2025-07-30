FactoryBot.define do
  factory :proposal_item

  factory :check_box_item_1, class: ProposalItem do
    label { 'check_box_item_1' }
  end

  factory :check_box_item_2, class: ProposalItem do
    label { 'check_box_item_2' }
  end

  factory :radio_button_item_3, class: ProposalItem do
    label { 'radio_button_item_3' }
  end

  factory :presentation_method, class: ProposalItem do
    label { 'presentation_method' }
  end

  factory :proposal_item_whether_it_can_be_published, class: ProposalItem do
    id { 3 }
    conference_id { 1 }
    label { 'whether_it_can_be_published' }

    trait :all_ok do
      params { '3' }
    end

    trait :only_slide do
      params { '4' }
    end

    trait :only_video do
      params { '5' }
    end

    trait :all_ng do
      params { '6' }
    end
  end
end
