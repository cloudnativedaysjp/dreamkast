class SponsorType < ApplicationRecord
  belongs_to :conference

  has_many :sponsors_sponsor_types
  has_many :sponsors, through: :sponsors_sponsor_types
end
