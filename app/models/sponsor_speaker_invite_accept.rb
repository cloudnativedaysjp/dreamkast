class SponsorSpeakerInviteAccept < ApplicationRecord
  belongs_to :conference
  belongs_to :sponsor
  belongs_to :sponsor_contact
  belongs_to :speaker
  belongs_to :sponsor_speaker_invite, dependent: :destroy
end
