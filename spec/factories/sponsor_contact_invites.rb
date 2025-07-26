# == Schema Information
#
# Table name: sponsor_contact_invites
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  sponsor_id    :integer          not null
#  email         :string(255)      not null
#  token         :string(255)      not null
#  expires_at    :datetime         not null
#
# Indexes
#
#  index_sponsor_contact_invites_on_conference_id  (conference_id)
#  index_sponsor_contact_invites_on_sponsor_id     (sponsor_id)
#

FactoryBot.define do
  factory :sponsor_contact_invite do
    email { 'contact@example.com' }
    token { SecureRandom.hex(50) }
    expires_at { 1.day.from_now }
    conference
    sponsor
  end
end
