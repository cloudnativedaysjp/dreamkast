class SponsorContact < ApplicationRecord
  include ActionView::Helpers::UrlHelper

  belongs_to :conference
  belongs_to :sponsor
  belongs_to :user
  has_many :sponsor_contact_invite_accepts, dependent: :destroy

  before_validation :ensure_user_id, on: :create

  validates :conference_id, presence: true
  validates :user_id, uniqueness: { scope: [:conference_id, :sponsor_id] }

  # 利便性のため、subとemailへのアクセスをuser経由で提供
  # userが存在する場合はuserの値を優先し、存在しない場合は既存のカラムの値を返す
  def sub
    user&.sub || read_attribute(:sub)
  end

  def email
    user&.email || read_attribute(:email)
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
