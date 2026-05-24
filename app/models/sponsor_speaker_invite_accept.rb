class SponsorSpeakerInviteAccept < ApplicationRecord
  belongs_to :conference
  belongs_to :sponsor
  belongs_to :sponsor_contact
  belongs_to :speaker
  belongs_to :sponsor_speaker_invite, dependent: :destroy

  # 1 Speaker は 1 Conference 内で高々 1 Sponsor にしか紐付かない
  validates :speaker_id,
            uniqueness: {
              scope: :conference_id,
              message: 'はすでに別スポンサーの登壇者として登録されています'
            }
end
