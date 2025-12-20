class SponsorContact < ApplicationRecord
  include ActionView::Helpers::UrlHelper

  belongs_to :conference
  belongs_to :sponsor
  belongs_to :user, optional: true
  has_many :sponsor_contact_invite_accepts, dependent: :destroy

  before_validation :ensure_user, on: :create

  validates :conference_id, presence: true
  validates :user_id, uniqueness: { scope: [:conference_id, :sponsor_id] }

  # userのsubとemailを委譲（userがnilの可能性がある場合はallow_nil: true）
  delegate :sub, :email, to: :user, allow_nil: true

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
      # user_idはnilのまま（承諾時に設定される）
    else
      errors.add(:base, 'subとemailのいずれかが必要です')
    end
  end
end
