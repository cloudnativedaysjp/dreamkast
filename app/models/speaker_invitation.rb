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
  validate :unique_talk_and_mail_with_acceptance
  validate :unique_talk_and_mail_with_non_expired_invitation

  private

  def unique_talk_and_mail_with_acceptance
    if SpeakerInvitation.joins(:speaker_invitation_accept)
                        .where(talk_id: talk_id, email: email)
                        .exists?
      errors.add(:base, "指定したプロポーザル（セッション）について、既に承認済の招待があります")
    end
  end

  def unique_talk_and_mail_with_non_expired_invitation
    if SpeakerInvitation.left_joins(:speaker_invitation_accept)
                        .where(talk_id: talk_id, email: email)
                        .where('expires_at > ?', Time.current)
                        .where(speaker_invitation_accepts: { id: nil })
                        .exists?
      errors.add(:base, "指定したプロポーザル（セッション）について、既に招待済みです")
    end
  end
end
