class SponsorForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attr_accessor :name
  attr_accessor :abbr
  attr_accessor :url
  attr_accessor :description
  attr_accessor :sponsor_types
  attr_accessor :attachment_logo_image

  delegate :persisted?, to: :sponsor

  def initialize(attributes = nil, sponsor: Sponsor.new)
    @sponsor = sponsor
    attributes ||= default_attributes
    super(attributes)
  end

  def sponsor
    @sponsor
  end

  def save
    return if invalid?

    ActiveRecord::Base.transaction do
      params = { name:, abbr:, url:, description: }
      params[:sponsor_types] = sponsor_types.map { |id| SponsorType.find(id) } if sponsor_types.present?
      sponsor.update!(params)
      if attachment_logo_image
        if sponsor.sponsor_attachment_logo_image.present?
          sponsor.sponsor_attachment_logo_image.update!(file: attachment_logo_image)
        else
          logo = SponsorAttachmentLogoImage.new(file: attachment_logo_image, sponsor_id: sponsor.id)
          logo.save!
        end
      end

      true
    end
  rescue => e
    puts(e)
    false
  end

  def to_model
    sponsor
  end

  def load
  end

  private

  attr_reader :sponsor

  def default_attributes
    {
      name: sponsor.name,
      abbr: sponsor.abbr,
      url: sponsor.url,
      description: sponsor.description,
      sponsor_types: sponsor.sponsor_types,
      attachment_logo_image: sponsor.sponsor_attachment_logo_image
    }
  end
end
