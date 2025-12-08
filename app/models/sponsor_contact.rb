class SponsorContact < ApplicationRecord
  include ActionView::Helpers::UrlHelper

  belongs_to :conference
  belongs_to :sponsor
  belongs_to :user
  has_many :sponsor_contact_invite_accepts, dependent: :destroy

  before_validation :ensure_user_id, on: :create

  validates :conference_id, presence: true

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
