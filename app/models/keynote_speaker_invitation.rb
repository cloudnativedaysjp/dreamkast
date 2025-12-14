class KeynoteSpeakerInvitation < ApplicationRecord
  belongs_to :conference
  belongs_to :speaker, optional: true
  belongs_to :talk, optional: true
  has_one :keynote_speaker_accept, dependent: :destroy

  validates :email, presence: true
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create
  after_create :create_provisional_data

  scope :pending, -> { where(accepted_at: nil).where('expires_at > ?', Time.current) }
  scope :accepted, -> { where.not(accepted_at: nil) }
  scope :expired, -> { where(accepted_at: nil).where('expires_at <= ?', Time.current) }

  def accepted?
    accepted_at.present?
  end

  def expired?
    !accepted? && expires_at <= Time.current
  end

  def pending?
    !accepted? && !expired?
  end

  def accept!(current_user_sub)
    ActiveRecord::Base.transaction do
      # SpeakerにAuth0のsubを設定（user経由）
      # current_user_subからUserを取得または作成
      user = User.find_or_create_by!(sub: current_user_sub) do |u|
        u.email = speaker.read_attribute(:email) || "#{current_user_sub}@example.com"
      end
      # Userのemailがspeakerのemailと異なる場合は更新
      speaker_email = speaker.read_attribute(:email)
      if user.email != speaker_email && speaker_email.present?
        user.update!(email: speaker_email)
      end
      # Speakerのuser_idを設定
      speaker.update!(user:)

      # 承諾記録の作成
      create_keynote_speaker_accept!(
        speaker:,
        talk:
      )

      # 承諾日時の記録
      update!(accepted_at: Time.current)
    end
  end

  private

  def generate_token
    self.token = SecureRandom.hex(32)
  end

  def set_expiration
    self.invited_at = Time.current
    self.expires_at = 7.days.from_now
  end

  def create_provisional_data
    ActiveRecord::Base.transaction do
      # 暫定Speakerの作成
      created_speaker = Speaker.create!(
        conference:,
        email:,
        name: name || 'キーノートスピーカー（未確定）',
        profile: 'プロフィール未設定',
        company: '所属未設定',
        job_title: '役職未設定'
      )

      # 暫定Talkの作成
      created_talk = Talk.create(
        conference:,
        title: 'キーノートセッション（仮）',
        abstract: 'セッション概要は後日更新されます。'
      )
      keynote_session_time = conference.proposal_item_configs.find_by(label: 'session_time', value: '20')
      created_talk.create_or_update_proposal_item('session_time', keynote_session_time.id.to_s)
      created_talk.save!

      # TalkTypeの設定（キーノートセッション）
      if defined?(TalkType) && TalkType::KEYNOTE_SESSION_ID
        created_talk.talk_types = [TalkType.find(TalkType::KEYNOTE_SESSION_ID)]
      end

      # Proposalの作成（採択済みステータス）
      Proposal.create!(
        conference:,
        talk: created_talk,
        status: 'registered'
      )

      # TalksSpeaker関連付け
      TalksSpeaker.create!(
        talk: created_talk,
        speaker: created_speaker
      )

      # 自身に関連付け
      update!(speaker: created_speaker, talk: created_talk)
    end
  end
end
