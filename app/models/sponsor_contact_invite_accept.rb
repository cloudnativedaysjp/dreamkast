class SponsorContactInviteAccept < ApplicationRecord
  belongs_to :conference
  belongs_to :sponsor
  belongs_to :sponsor_contact
  belongs_to :sponsor_contact_invite
end
