class AdminProfile < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  include AvatarUploader::Attachment(:avatar)

  belongs_to :conference
  belongs_to :user, required: true

  before_validation :ensure_user, on: :create

  validates :user_id, uniqueness: { scope: :conference_id }

  # userのsubとemailを委譲（userは必須なのでallow_nilは不要）
  delegate :sub, :email, to: :user

  # 一時的な属性（before_validationでuserを作成するために使用）
  attr_accessor :pending_sub, :pending_email

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

  def has_avatar?
    !avatar_url.nil?
  end

  def avatar_or_dummy_url(size = :small)
    if has_avatar?
      avatar_url(size) || avatar_url
    else
      'dummy.png'
    end
  end

  def twitter_link
    link_to(ActionController::Base.helpers.image_tag('Twitter_X_Logo_Icon_Round_Black.png', width: 20), "https://twitter.com/#{twitter_id}") if twitter_id.present?
  end

  def github_link
    link_to(ActionController::Base.helpers.image_tag('GitHub-Mark-64px.png', width: 20), "https://github.com/#{github_id}") if github_id.present?
  end

  private

  def ensure_user
    return if user_id.present?

    sub_value = pending_sub
    email_value = pending_email

    if sub_value.present? && email_value.present?
      self.user = User.find_or_create_by!(sub: sub_value) do |u|
        u.email = email_value
      end
      # emailが指定されていて、Userのemailが異なる場合は更新
      if user.email != email_value
        user.update!(email: email_value)
      end
    else
      errors.add(:base, 'subとemailの両方が必要です')
    end
  end
end
