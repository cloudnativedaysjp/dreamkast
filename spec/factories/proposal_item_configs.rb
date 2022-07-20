# == Schema Information
#
# Table name: proposal_item_configs
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  type          :string(255)
#  item_number   :integer
#  label         :string(255)
#  item_name     :string(255)
#  params        :json
#  description   :text(65535)
#  key           :string(255)
#  value         :string(255)
#
# Indexes
#
#  index_proposal_item_configs_on_conference_id  (conference_id)
#

FactoryBot.define do
  factory :check_box_item_config_1, class: ProposalItemConfig do
    type { 'ProposalItemConfigCheckBox' }
    label { 'check_box_item_1' }
    item_number { 1 }
    item_name { 'チェックボックス1' }
  end

  factory :check_box_item_config_2, class: ProposalItemConfig do
    type { 'ProposalItemConfigCheckBox' }
    label { 'check_box_item_2' }
    item_number { 2 }
    item_name { 'チェックボックス2' }
  end

  factory :radio_button_item_config_3, class: ProposalItemConfig do
    type { 'ProposalItemConfigRadioButton' }
    label { 'radio_button_item_3' }
    item_number { 3 }
    item_name { 'ラジオボタン3' }
  end

  factory :radio_button_item_config_4, class: ProposalItemConfig do
    type { 'ProposalItemConfigRadioButton' }
    label { 'radio_button_item_4' }
    item_number { 4 }
    item_name { 'ラジオボタン4' }
  end

  factory :proposal_item_configs_expected_participant, class: ProposalItemConfig do
    id { 1 }
    conference_id { 1 }
    type { 'ProposalItemConfigCheckBox' }
    label { 'expected_participant' }
    item_number { 1 }
    item_name { '想定受講者（★★）' }
    params { 'architect - システム設計' }
  end

  factory :proposal_item_configs_execution_phase, class: ProposalItemConfig do
    id { 2 }
    conference_id { 1 }
    type { 'ProposalItemConfigCheckBox' }
    label { 'execution_phases' }
    item_number { 1 }
    item_name { '実行フェーズ（★★）' }
    params { 'Dev/QA（開発環境）' }
  end

  factory :proposal_item_configs_assumed_visitor, class: ProposalItemConfig do
    type { 'ProposalItemConfigCheckBox' }
    label { 'assumed_visitor' }
    item_number { 1 }
    item_name { '想定受講者（★★）' }
    params { 'architect - システム設計' }
  end

  factory :proposal_item_configs_presentation_method, class: ProposalItemConfig do
    type { 'ProposalItemConfigRadioButton' }
    label { 'presentation_method' }
    item_number { 1 }
    item_name { '登壇方法の希望' }
    params { '現地登壇' }

    trait :live do
      params { 'オンライン登壇' }
    end

    trait :video do
      params { '事前収録' }
    end
  end

  factory :proposal_item_configs_session_time, class: ProposalItemConfig do
    type { 'ProposalItemConfigRadioButton' }
    label { 'session_time' }
    item_number { 1 }
    item_name { '必要とする講演時間 - Session time you need（★）' }
    params { '40min (full session)' }
  end

  factory :proposal_item_configs_whether_it_can_be_published, class: ProposalItemConfig do
    conference_id { 1 }
    type { 'ProposalItemConfigRadioButton' }
    label { 'whether_it_can_be_published' }
    item_number { 1 }
    item_name { 'スライドと動画の公開可否（★★）' }
    params { 'All okay - スライド・動画両方ともに公開可' }

    trait :all_ok do
      id { 3 }
      params { 'All okay - スライド・動画両方ともに公開可' }
      key { 1 }
      value { 'All okay - スライド・動画両方ともに公開可' }
    end

    trait :only_slide do
      id { 4 }
      params { 'Only Slide - スライドのみ公開可' }
      key { 2 }
      value { 'Only Slide - スライドのみ公開可' }
    end

    trait :only_video do
      id { 5 }
      params { 'Only Video - 動画のみ公開可' }
      key { 3 }
      value { 'Only Video - 動画のみ公開可' }
    end

    trait :all_ng do
      id { 5 }
      params { 'NG - いずれも公開不可（来場者限定のコンテンツ）' }
      key { 4 }
      value { 'NG - いずれも公開不可（来場者限定のコンテンツ）' }
    end
  end
end
