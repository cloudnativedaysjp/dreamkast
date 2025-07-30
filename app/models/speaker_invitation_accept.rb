class SpeakerInvitationAccept < ApplicationRecord
  belongs_to :speaker_invitation
  belongs_to :conference
  belongs_to :speaker
  belongs_to :talk
end
