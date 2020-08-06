class SponsorForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :sponsor_id, :integer, default: nil
  attribute :description, :string, default: ""

  def initialize(params: {})
    super(params)
    @sponsor = params[:sponsor_id] ? Sponsor.find_by(id: params[:sponsor_id]) : Sponsor.new
  end
  def save!
    raise ActiveRecord::RecordInvalid if invalid?
    ActiveRecord::Base.transaction do
      @sponsor.save!(description: description)
    end
  end

  def description
    @sponsor.description
  end
end