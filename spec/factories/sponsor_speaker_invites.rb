# == Schema Information
#
# Table name: sponsor_speaker_invites
#
#  id            :bigint           not null, primary key
#  email         :string(255)      not null
#  expires_at    :datetime         not null
#  token         :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#  sponsor_id    :bigint           not null
#
# Indexes
#
#  index_sponsor_speaker_invites_on_conference_id  (conference_id)
#  index_sponsor_speaker_invites_on_sponsor_id     (sponsor_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (sponsor_id => sponsors.id)
#

FactoryBot.define do
  factory :sponsor_speaker_invite do
    email { 'speaker@example.com' }
    token { SecureRandom.hex(50) }
    expires_at { 1.day.from_now }
    conference
    sponsor
  end
end
