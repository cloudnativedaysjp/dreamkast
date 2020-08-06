class SponsorForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attr_accessor :description, :attachment_text

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
    }
  end
end