class Booth < ApplicationRecord
  belongs_to :conference
  belongs_to :sponsor

  def sponsor_text
    sponsor.sponsor_attachment_text.present? ? sponsor.sponsor_attachment_text.text : ''
  end

  def logo_url
    sponsor.sponsor_attachment_logo_image ? sponsor.sponsor_attachment_logo_image.url : ''
  end

  def vimeo_url
    sponsor.sponsor_attachment_vimeo.present? ? sponsor.sponsor_attachment_vimeo.url : ''
  end

  def miro_url
    sponsor.sponsor_attachment_miro.present? ? sponsor.sponsor_attachment_miro.url : ''
  end

  def pdf_urls
    sponsor.sponsor_attachment_pdfs.present? ? sponsor.sponsor_attachment_pdfs.map{|pdf| {url: pdf.file_url, title: pdf.title}} : []
  end

  def key_image_urls
    sponsor.sponsor_attachment_key_images.present? ? sponsor.sponsor_attachment_key_images.map{|image| image.file_url} : []
  end
end