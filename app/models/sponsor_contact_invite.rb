class SponsorContactInvite < ApplicationRecord
  belongs_to :conference
  belongs_to :sponsor
  has_many :sponsor_contact_invite_accepts

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validate :expires_at_must_be_future

  private

  def expires_at_must_be_future
    if expires_at.present? && expires_at < Time.current
      errors.add(:expires_at, 'must be in the future')
    end
  end
end
