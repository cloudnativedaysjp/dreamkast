class Sponsor < ApplicationRecord
  belongs_to :conference
  has_one :sponsor_attachment_text
  has_one :sponsor_attachment_logo_image
  has_many :sponsor_attachment_pdfs
  has_many :sponsor_attachment_youtubes
  has_many :sponsor_attachment_vimeos
  has_many :sponsor_attachment_key_images

  has_many :sponsors_sponsor_types
  has_many :sponsor_types, through: :sponsors_sponsor_types

  accepts_nested_attributes_for :sponsor_attachment_key_images
  accepts_nested_attributes_for :sponsor_attachment_text
  accepts_nested_attributes_for :sponsor_attachment_youtubes
  accepts_nested_attributes_for :sponsor_attachment_pdfs
end
