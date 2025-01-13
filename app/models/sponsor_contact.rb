# == Schema Information
#
# Table name: sponsor_contacts
#
#  id            :bigint           not null, primary key
#  email         :string(255)
#  name          :string(255)
#  sub           :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#  sponsor_id    :bigint           not null
#
# Indexes
#
#  index_sponsor_contacts_on_conference_id  (conference_id)
#  index_sponsor_contacts_on_sponsor_id     (sponsor_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#

class SponsorContact < ApplicationRecord
  include ActionView::Helpers::UrlHelper

  belongs_to :conference
  belongs_to :sponsor
  has_many :sponsor_contact_invite_accepts, dependent: :destroy

  validates :conference_id, presence: true
end
