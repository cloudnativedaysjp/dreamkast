class Sponsor < ApplicationRecord
  belongs_to :conference
  has_one :sponsor_attachment_text
  has_one :sponsor_attachment_logo_image
  has_many :sponsor_attachment_pdfs
  has_one :sponsor_attachment_youtube
  has_many :sponsor_attachment_vimeos
  has_many :sponsor_attachment_key_images

  has_many :sponsors_sponsor_types
  has_many :sponsor_types, through: :sponsors_sponsor_types

end
