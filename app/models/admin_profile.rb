class AdminProfile < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  include AvatarUploader::Attachment(:avatar)

  belongs_to :conference
  belongs_to :user

  before_validation :ensure_user_id, on: :create

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
