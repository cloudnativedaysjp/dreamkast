class AdminProfile < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  include AvatarUploader::Attachment(:avatar)

  belongs_to :conference
  belongs_to :user

  before_validation :ensure_user_id, on: :create

  validates :user_id, uniqueness: { scope: :conference_id }

  # 利便性のため、subとemailへのアクセスをuser経由で提供
  # userが存在する場合はuserの値を優先し、存在しない場合は既存のカラムの値を返す
  def sub
    user&.sub || read_attribute(:sub)
  end

  def email
    user&.email || read_attribute(:email)
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

  def ensure_user_id
    return if user_id.present?

    # 既存のカラムの値を直接読み取る
    sub_value = read_attribute(:sub)
    email_value = read_attribute(:email)

    if sub_value.present?
      user = User.find_or_create_by!(sub: sub_value) do |u|
        u.email = email_value || "#{sub_value}@example.com"
      end
    elsif email_value.present?
      temp_sub = "temp_#{SecureRandom.hex(8)}"
      user = User.find_or_create_by!(email: email_value) do |u|
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
