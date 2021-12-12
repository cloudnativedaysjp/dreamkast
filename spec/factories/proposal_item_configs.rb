# == Schema Information
#
# Table name: proposal_item_configs
#
#  id            :bigint           not null, primary key
#  description   :text(65535)
#  item_name     :string(255)
#  item_number   :integer
#  key           :string(255)
#  label         :string(255)
#  params        :json
#  type          :string(255)
#  value         :string(255)
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

  factory :proposal_item_configs_whether_it_can_be_published, class: ProposalItemConfig do
    conference_id { 1 }
    type { "ProposalItemConfigRadioButton" }
    label { "whether_it_can_be_published" }
    item_number { 1 }
    item_name { "スライドと動画の公開可否（★★）" }
    params { "All okay - スライド・動画両方ともに公開可" }

    trait :all_ok do
      id { 3 }
      params { "All okay - スライド・動画両方ともに公開可" }
      key { 1 }
      value { "All okay - スライド・動画両方ともに公開可" }
    end

    trait :only_slide do
      id { 4 }
      params { "Only Slide - スライドのみ公開可" }
      key { 2 }
      value { "Only Slide - スライドのみ公開可" }
    end

    trait :only_video do
      id { 5 }
      params { "Only Video - 動画のみ公開可" }
      key { 3 }
      value { "Only Video - 動画のみ公開可" }
    end

    trait :all_ng do
      id { 5 }
      params { "NG - いずれも公開不可（来場者限定のコンテンツ）" }
      key { 4 }
      value { "NG - いずれも公開不可（来場者限定のコンテンツ）" }
    end
  end
end
