# == Schema Information
#
# Table name: sponsor_types
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  name          :string(255)
#  order         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_sponsor_types_on_conference_id  (conference_id)
#

FactoryBot.define do
  factory :sponsor_type do
    conference { nil }
    name { 'MyString' }
  end
end
