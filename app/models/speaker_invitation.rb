# == Schema Information
#
# Table name: speaker_invitations
#
#  id            :bigint           not null, primary key
#  email         :string(255)      not null
#  expires_at    :datetime         not null
#  token         :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#  talk_id       :bigint           not null
#
# Indexes
#
#  index_speaker_invitations_on_conference_id  (conference_id)
#  index_speaker_invitations_on_talk_id        (talk_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (talk_id => talks.id)
#
class SpeakerInvitation < ApplicationRecord
  belongs_to :talk
  belongs_to :conference

  has_one :speaker_invitation_accept, dependent: :destroy


  validates :email, presence: true
  validates :token, presence: true
end
