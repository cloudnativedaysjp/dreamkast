# == Schema Information
#
# Table name: proposal_item_configs
#
#  id            :bigint           not null, primary key
#  description   :text(65535)
#  item_name     :string(255)
#  item_number   :integer
#  label         :string(255)
#  params        :json
#  type          :string(255)
#  conference_id :bigint           not null
#
# Indexes
#
#  index_proposal_item_configs_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
FactoryBot.define do
  factory :proposal_item_configs_expected_participant, class: ProposalItemConfig do
    id { 1 }
    conference_id { 1 }
    type { "ProposalItemConfigCheckBox" }
    label { "expected_participant" }
    item_number { 1 }
    item_name { "\u60F3\u5B9A\u53D7\u8B1B\u8005\uFF08\u2605\u2605\uFF09" }
    params { "architect - \u30B7\u30B9\u30C6\u30E0\u8A2D\u8A08" }
  end
  factory :proposal_item_configs_execution_phase, class: ProposalItemConfig do
    id { 2 }
    conference_id { 1 }
    type { "ProposalItemConfigCheckBox" }
    label { "execution_phases" }
    item_number { 1 }
    item_name { "\u5B9F\u884C\u30D5\u30A7\u30FC\u30BA\uFF08\u2605\u2605\uFF09" }
    params { "Dev/QA\uFF08\u958B\u767A\u74B0\u5883\uFF09" }
  end
end
