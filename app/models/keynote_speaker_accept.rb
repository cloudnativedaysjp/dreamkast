class KeynoteSpeakerAccept < ApplicationRecord
  belongs_to :keynote_speaker_invitation
  belongs_to :speaker
  belongs_to :talk

  validates :keynote_speaker_invitation_id, uniqueness: true
end
