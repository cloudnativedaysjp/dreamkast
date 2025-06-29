# == Schema Information
#
# Table name: sponsors
#
#  id            :bigint           not null, primary key
#  abbr          :string(255)
#  description   :text(65535)
#  name          :string(255)
#  url           :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#
# Indexes
#
#  index_sponsors_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#

class Sponsor < ApplicationRecord
  belongs_to :conference

  has_one :sponsor_attachment_logo_image, dependent: :delete

  has_many :sponsor_contacts, dependent: :delete_all
  has_many :sponsor_contact_invites, dependent: :delete_all
  has_many :sponsors_sponsor_types, dependent: :delete_all
  has_many :sponsor_types, through: :sponsors_sponsor_types
  has_many :talks
  has_many :speakers
  has_many :stamp_rally_check_point_booths
  has_many :sponsor_speaker_invites, dependent: :delete_all

  def booth_sponsor?
    sponsor_types.each do |type|
      if type.name == 'Booth'
        return true
      end
    end
    false
  end

  def logo_url
    if sponsor_attachment_logo_image&.file_data&.present?
      sponsor_attachment_logo_image&.file_url
    else
      sponsor_attachment_logo_image&.url
    end
  end
end
