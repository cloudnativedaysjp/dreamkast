class SponsorForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attr_accessor :description,
                :attachment_key_image_1, :attachment_key_image_1_title,
                :attachment_key_image_2, :attachment_key_image_2_title,
                :attachment_text,
                :attachment_vimeo,
                :attachment_pdf_1, :attachment_pdf_1_title,
                :attachment_pdf_2, :attachment_pdf_2_title,
                :attachment_pdf_3, :attachment_pdf_3_title

  delegate :persisted?, to: :sponsor

  def initialize(attributes = nil, sponsor: Sponsor.new)
    @sponsor = sponsor
    attributes ||= default_attributes
    super(attributes)
  end

  def save
    return if invalid?

    ActiveRecord::Base.transaction do
      sponsor.update!(description: description)
      sponsor.sponsor_attachment_key_images[0].update!(title: attachment_key_image_1_title, file: attachment_key_image_1)
      sponsor.sponsor_attachment_key_images[1].update!(title: attachment_key_image_2_title, file: attachment_key_image_2)
      sponsor.sponsor_attachment_text.update!(text: attachment_text)
      sponsor.sponsor_attachment_vimeo.update!(url: attachment_vimeo)
      sponsor.sponsor_attachment_pdfs[0].update!(title: attachment_pdf_1_title, file: attachment_pdf_1)
      sponsor.sponsor_attachment_pdfs[1].update!(title: attachment_pdf_2_title, file: attachment_pdf_2)
      sponsor.sponsor_attachment_pdfs[2].update!(title: attachment_pdf_3_title, file: attachment_pdf_3)
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  def to_model
    sponsor
  end

  private

  attr_reader :sponsor

  def default_attributes
    {
      description: sponsor.description,
      attachment_text: sponsor.sponsor_attachment_text.text,
      attachment_key_image_1_title: sponsor.sponsor_attachment_key_images[0].present? ? sponsor.sponsor_attachment_key_images[0].title : '',
      attachment_key_image_2_title: sponsor.sponsor_attachment_key_images[1].present? ? sponsor.sponsor_attachment_key_images[1].title : '',
      attachment_vimeo: sponsor.sponsor_attachment_vimeo.present? ? sponsor.sponsor_attachment_vimeo.url : '',
      attachment_pdf_1_title: sponsor.sponsor_attachment_pdfs[0].present? ? sponsor.sponsor_attachment_pdfs[0].title : '',
      attachment_pdf_2_title: sponsor.sponsor_attachment_pdfs[1].present? ? sponsor.sponsor_attachment_pdfs[1].title : '',
      attachment_pdf_3_title: sponsor.sponsor_attachment_pdfs[2].present? ? sponsor.sponsor_attachment_pdfs[2].title : ''
    }
  end
end