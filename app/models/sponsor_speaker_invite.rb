class SponsorSpeakerInvite < ApplicationRecord
  belongs_to :conference
  belongs_to :sponsor
  has_many :sponsor_speaker_invite_accepts, dependent: :destroy

  validates :email, presence: true
  validates :token, presence: true
end
