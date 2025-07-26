# == Schema Information
#
# Table name: sponsors_sponsor_types
#
#  id              :integer          not null, primary key
#  sponsor_id      :integer
#  sponsor_type_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryBot.define do
  factory :sponsors_sponsor_type do
  end
end
