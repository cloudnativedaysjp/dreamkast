FactoryBot.define do
  factory :proposal_item_configs_expected_participant, class: ProposalItemConfig do
    id { 1 }
    conference_id { 1 }
    type { 'ProposalItemConfigCheckBox' }
    label { 'expected_participant' }
    item_number { 1 }
    item_name { '想定受講者（★★）' }
    params { 'architect - システム設計' }
  end
  factory :proposal_item_configs_execution_phase, class: ProposalItemConfig  do
    id { 2 }
    conference_id { 1 }
    type { 'ProposalItemConfigCheckBox' }
    label { 'execution_phases' }
    item_number { 1 }
    item_name { '実行フェーズ（★★）' }
    params { 'Dev/QA（開発環境）' }
  end
end
