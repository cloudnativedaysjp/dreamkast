class SponsorProfile < ApplicationRecord
  include ActionView::Helpers::UrlHelper

  belongs_to :conference
  belongs_to :sponsor

  validates :conference_id, presence: true
end
