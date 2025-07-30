class SponsorsSponsorType < ApplicationRecord
  belongs_to :sponsor, optional: true
  belongs_to :sponsor_type, optional: true

  def self.updatable_attributes
    %w[sponsor_id sponsor_type_id]
  end
end
