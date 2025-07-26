# == Schema Information
#
# Table name: sponsor_contact_invites
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  sponsor_id    :integer          not null
#  email         :string(255)      not null
#  token         :string(255)      not null
#  expires_at    :datetime         not null
#
# Indexes
#
#  index_sponsor_contact_invites_on_conference_id  (conference_id)
#  index_sponsor_contact_invites_on_sponsor_id     (sponsor_id)
#

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
