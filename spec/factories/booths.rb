# == Schema Information
#
# Table name: booths
#
#  id            :bigint           not null, primary key
#  published     :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#  sponsor_id    :bigint           not null
#
# Indexes
#
#  index_booths_on_conference_id  (conference_id)
#  index_booths_on_sponsor_id     (sponsor_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (sponsor_id => sponsors.id)
#
FactoryBot.define do
  factory :boothe do
    sponsor { nil }
    published { '' }
  end
end
