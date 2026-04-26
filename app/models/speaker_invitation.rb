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
                        .where(talk_id:, email:)
                        .exists?
      errors.add(:base, '指定したプロポーザル（セッション）について、既に承認済の招待があります')
    end
  end

  def unique_talk_and_mail_with_non_expired_invitation
    if SpeakerInvitation.left_joins(:speaker_invitation_accept)
                        .where(talk_id:, email:)
                        .where('expires_at > ?', Time.current)
                        .where(speaker_invitation_accepts: { id: nil })
                        .exists?
      errors.add(:base, '指定したプロポーザル（セッション）について、既に招待済みです')
    end
  end
end
