# == Schema Information
#
# Table name: sponsors
#
#  id             :bigint           not null, primary key
#  abbr           :string(255)
#  description    :text(65535)
#  name           :string(255)
#  speaker_emails :string(255)
#  url            :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  conference_id  :bigint           not null
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

  has_one :sponsor_attachment_text, dependent: :delete
  has_one :sponsor_attachment_logo_image, dependent: :delete
  has_one :sponsor_attachment_vimeo, dependent: :delete
  has_one :sponsor_attachment_zoom, dependent: :delete
  has_one :sponsor_attachment_miro, dependent: :delete
  has_one :booth, dependent: :delete

  has_many :sponsor_attachment_pdfs, dependent: :delete_all
  has_many :sponsor_attachment_key_images, dependent: :delete_all
  has_many :sponsors_sponsor_types, dependent: :delete_all
  has_many :sponsor_types, through: :sponsors_sponsor_types
  has_many :talks

  def booth_info
    { id: booth.id, opened: booth.published }
  end

  def booth_sponsor?
    sponsor_types.each do |type|
      if type.name == 'Booth'
        return true
      end
    end
    false
  end
end
