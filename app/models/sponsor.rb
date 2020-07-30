class Sponsor < ApplicationRecord
  belongs_to :conference
  has_many :sponsor_attachment_texts
  has_many :sponsor_attachment_images
  has_many :sponsor_attachment_pdfs
  has_many :sponsor_attachment_youtubes
  has_many :sponsor_attachment_vimeos
end
