# == Schema Information
#
# Table name: sponsor_profiles
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  sub           :string(255)
#  email         :string(255)
#  conference_id :integer          not null
#  sponsor_id    :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_sponsor_profiles_on_conference_id  (conference_id)
#  index_sponsor_profiles_on_sponsor_id     (sponsor_id)
#

class SponsorProfile < ApplicationRecord
  include ActionView::Helpers::UrlHelper

  belongs_to :conference
  belongs_to :sponsor

  validates :conference_id, presence: true
end
