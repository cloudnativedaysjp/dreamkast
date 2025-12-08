class Speaker < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  include AvatarUploader::Attachment(:avatar)

  belongs_to :conference
  belongs_to :sponsor, optional: true
  belongs_to :user

  has_many :talks_speakers
  has_many :talks, through: :talks_speakers
  has_many :speaker_announcement_middles
  has_many :speaker_announcements, through: :speaker_announcement_middles
  has_many :sponsor_speaker_invite_accepts, dependent: :destroy

  before_validation :ensure_user_id, on: :create

  validates :name, presence: true
  validates :profile, presence: true
  validates :company, presence: true
  validates :job_title, presence: true
  validates :conference_id, presence: true

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

  private

  def ensure_user_id
    return if user_id.present?

    if sub.present?
      user = User.find_or_create_by!(sub:) do |u|
        u.email = email || "#{sub}@example.com"
      end
    elsif email.present?
      temp_sub = "temp_#{SecureRandom.hex(8)}"
      user = User.find_or_create_by!(email:) do |u|
        u.sub = temp_sub
      end
    else
      # subもemailもnilの場合は、一時的なUserを作成
      temp_sub = "temp_#{SecureRandom.hex(8)}"
      temp_email = "temp_#{SecureRandom.hex(8)}@temp.local"
      user = User.create!(sub: temp_sub, email: temp_email)
    end
    self.user_id = user.id
  end
end
