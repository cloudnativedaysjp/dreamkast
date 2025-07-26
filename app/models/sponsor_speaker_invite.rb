# == Schema Information
#
# Table name: sponsor_speaker_invites
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  sponsor_id    :integer          not null
#  email         :string(255)      not null
#  token         :string(255)      not null
#  expires_at    :datetime         not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_sponsor_speaker_invites_on_conference_id  (conference_id)
#  index_sponsor_speaker_invites_on_sponsor_id     (sponsor_id)
#

class SponsorSpeakerInvite < ApplicationRecord
  belongs_to :conference
  belongs_to :sponsor
  has_many :sponsor_speaker_invite_accepts, dependent: :destroy

  validates :email, presence: true
  validates :token, presence: true
end
