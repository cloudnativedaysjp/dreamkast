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
  factory :proposal_item_whether_it_can_be_published, class: ProposalItem do
    id { 3 }
    conference_id { 1 }
    label { "whether_it_can_be_published" }

    trait :all_ok do
      params { "3" }
    end

    trait :only_slide do
      params { "4" }
    end

    trait :only_video do
      params { "5" }
    end

    trait :all_ng do
      params { "5" }
    end
  end
end
