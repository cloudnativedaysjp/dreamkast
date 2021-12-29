FactoryBot.define do
  factory :check_box_item_1, class: ProposalItem do
    label { 'check_box_item_1' }
  end

  factory :check_box_item_2, class: ProposalItem do
    label { 'check_box_item_2' }
  end

  factory :radio_button_item_3, class: ProposalItem do
    label { 'radio_button_item_3' }
  end
end
