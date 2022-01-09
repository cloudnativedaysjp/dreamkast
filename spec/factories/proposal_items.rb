# == Schema Information
#
# Table name: proposal_items
#
#  id            :bigint           not null, primary key
#  label         :string(255)
#  params        :json
#  conference_id :bigint           not null
#  talk_id       :bigint           not null
#
# Indexes
#
#  index_proposal_items_on_conference_id  (conference_id)
#  index_proposal_items_on_talk_id        (talk_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
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
