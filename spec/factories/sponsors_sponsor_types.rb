# == Schema Information
#
# Table name: sponsors_sponsor_types
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sponsor_id      :integer
#  sponsor_type_id :integer
#
FactoryBot.define do
  factory :sponsors_sponsor_type do
  end
end
