# == Schema Information
#
# Table name: sponsor_contact_invite_accepts
#
#  id                        :bigint           not null, primary key
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  conference_id             :bigint           not null
#  sponsor_contact_id        :bigint           not null
#  sponsor_contact_invite_id :bigint           not null
#  sponsor_id                :bigint           not null
#
# Indexes
#
#  index_sponsor_contact_invite_accepts_on_conference_id       (conference_id)
#  index_sponsor_contact_invite_accepts_on_invitation_id       (sponsor_contact_invite_id)
#  index_sponsor_contact_invite_accepts_on_sponsor_contact_id  (sponsor_contact_id)
#  index_sponsor_contact_invite_accepts_on_sponsor_id          (sponsor_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (sponsor_contact_id => sponsor_contacts.id)
#  fk_rails_...  (sponsor_contact_invite_id => sponsor_contact_invites.id)
#  fk_rails_...  (sponsor_id => sponsors.id)
#

FactoryBot.define do
  factory :sponsor_contact_invite_accept do
    conference
    sponsor
    sponsor_contact
    sponsor_contact_invite
  end
end
