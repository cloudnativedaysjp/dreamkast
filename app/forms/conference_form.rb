class ConferenceForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attr_accessor :status, :speaker_entry, :attendee_entry

  delegate :persisted?, to: :conference

  concerning :ConferenceLinksBuilder do
    attr_accessor :links

    def links
      @links ||= []
    end

    def links_attributes=(attributes)
      @links ||= []
      attributes.each do |i, params|
        if params.key?(:id)
          if params[:_destroy] == "1"
            link = @conference.links.find(params[:id])
            link.destroy
          else
            params.delete(:_destroy)
            link = @conference.links.find(params[:id])
            link.update(params)
          end
        else
          params.delete(:_destroy)
          link = Link.new(params.merge(conference_id: conference.id))
          link.save!
          @links.push(link)
        end
      end
    rescue => e
      puts e
      false
    end
  end

  def initialize(attributes = nil, conference: Conference.new)
    @conference = conference
    attributes ||= default_attributes
    super(attributes)
  end

  def conference
    @conference
  end

  def save
    return if invalid?

    ActiveRecord::Base.transaction do
      conference.update!(status: status, speaker_entry: speaker_entry, attendee_entry: attendee_entry)
    end

  rescue => e
    puts e
    false
  end

  def to_model
    conference
  end

  def load
    @links = @conference.links
  end

  attr_reader :conference

  private

  def default_attributes
    {
      status: conference.status,
      speaker_entry: conference.speaker_entry,
      attendee_entry: conference.attendee_entry,
      links: links
    }
  end
end