class Speaker < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  include AvatarUploader::Attachment(:avatar)

  belongs_to :conference
  belongs_to :sponsor, optional: true
  belongs_to :user, optional: true

  has_many :talks_speakers
  has_many :talks, through: :talks_speakers
  has_many :speaker_announcement_middles
  has_many :speaker_announcements, through: :speaker_announcement_middles
  has_many :sponsor_speaker_invite_accepts, dependent: :destroy

  before_validation :ensure_user, on: :create

  validates :name, presence: true
  validates :profile, presence: true
  validates :company, presence: true
  validates :job_title, presence: true
  validates :conference_id, presence: true
  validates :user_id, uniqueness: { scope: :conference_id }

  # userのsubとemailを委譲（userがnilの可能性がある場合はallow_nil: true）
  delegate :sub, :email, to: :user, allow_nil: true

  # 一時的な属性（before_validationでuserを作成するために使用）
  attr_accessor :pending_sub, :pending_email

  def proposals
    talks.map(&:proposal)
  end

  def sponsor_talks
    talks.filter { |talk| talk.sponsor.present? }
  end

  def self.export
    CSV.generate do |csv|
      csv << updatable_attributes
      Speaker.all.each do |speaker|
        csv << speaker.attributes.values_at(*updatable_attributes)
      end
    end
  end

  def self.updatable_attributes
    %w[id conference_id name profile company job_title twitter_id github_id avatar_data]
  end

  def has_avatar?
    !avatar_url.nil?
  end

  def avatar_or_dummy_url(size = :medium)
    if has_avatar?
      avatar_url(size) || avatar_url
    else
      'dummy.png'
    end
  end

  def avatar_full_url
    if has_avatar?
      "https://#{ENV.fetch('S3_BUCKET', '')}.s3.#{ENV.fetch('S3_REGION', '')}.amazonaws.com#{avatar_url}"
    end
  end

  def twitter_link
    link_to(ActionController::Base.helpers.image_tag('Twitter_X_Logo_Icon_Round_Black.png', width: 20), "https://twitter.com/#{twitter_id}") if twitter_id.present?
  end

  def github_link
    link_to(ActionController::Base.helpers.image_tag('GitHub-Mark-64px.png', width: 20), "https://github.com/#{github_id}") if github_id.present?
  end

  def has_accepted_proposal?
    talks.find { |e| e.proposal.status == 'accepted' }.present?
  end

  def attendee_profile
    conference.profiles.where(user_id:).first
  end

  # 既存コードとの互換性のため、セッターを提供
  def sub=(value)
    if user_id.present?
      user.update!(sub: value)
    else
      self.pending_sub = value
    end
  end

  def email=(value)
    if user_id.present?
      user.update!(email: value)
    else
      self.pending_email = value
    end
  end

  private

  def ensure_user
    return if user_id.present?

    sub_value = pending_sub
    email_value = pending_email

    if sub_value.present? && email_value.present?
      # 通常のケース：subとemailの両方が指定されている
      self.user = User.find_or_create_by!(sub: sub_value) do |u|
        u.email = email_value
      end
      # emailが指定されていて、Userのemailが異なる場合は更新
      if user.email != email_value
        user.update!(email: email_value)
      end
    elsif email_value.present?
      # 招待のケース：emailのみが指定されている
      # user_idはnilのまま（承諾時にaccept!メソッドで設定される）
    else
      errors.add(:base, 'subとemailのいずれかが必要です')
    end
  end
end
