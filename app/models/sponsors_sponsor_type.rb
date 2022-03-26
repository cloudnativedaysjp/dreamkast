# == Schema Information
#
# Table name: sponsors_sponsor_types
#
#  id              :integer          not null, primary key
#  sponsor_id      :integer
#  sponsor_type_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class SponsorsSponsorType < ApplicationRecord
  belongs_to :sponsor, optional: true
  belongs_to :sponsor_type, optional: true

  def self.updatable_attributes
    %w[sponsor_id sponsor_type_id]
  end
end
