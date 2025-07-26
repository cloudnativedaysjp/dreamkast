# == Schema Information
#
# Table name: sponsor_contact_invite_accepts
#
#  id                        :integer          not null, primary key
#  sponsor_contact_invite_id :integer          not null
#  conference_id             :integer          not null
#  sponsor_id                :integer          not null
#  sponsor_contact_id        :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_sponsor_contact_invite_accepts_on_conference_id       (conference_id)
#  index_sponsor_contact_invite_accepts_on_invitation_id       (sponsor_contact_invite_id)
#  index_sponsor_contact_invite_accepts_on_sponsor_contact_id  (sponsor_contact_id)
#  index_sponsor_contact_invite_accepts_on_sponsor_id          (sponsor_id)
#

class SponsorContactInviteAccept < ApplicationRecord
  belongs_to :conference
  belongs_to :sponsor
  belongs_to :sponsor_contact
  belongs_to :sponsor_contact_invite
end
