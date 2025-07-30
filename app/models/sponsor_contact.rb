class SponsorContact < ApplicationRecord
  include ActionView::Helpers::UrlHelper

  belongs_to :conference
  belongs_to :sponsor
  has_many :sponsor_contact_invite_accepts, dependent: :destroy

  validates :conference_id, presence: true
end
