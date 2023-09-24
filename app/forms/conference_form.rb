class ConferenceForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attr_accessor :conference_status
  attr_accessor :rehearsal_mode
  attr_accessor :cfp_result_visible
  attr_accessor :speaker_entry
  attr_accessor :attendee_entry
  attr_accessor :show_timetable
  attr_accessor :show_sponsors
  attr_accessor :capacity
  attr_accessor :brief
  attr_accessor :privacy_policy
  attr_accessor :privacy_policy_for_speaker

  delegate :persisted?, to: :conference

  concerning :ConferenceLinksBuilder do
    attr_accessor :links

    def links
      @links ||= []
    end

    def links_attributes=(attributes)
      @links ||= []
      attributes.each do |_i, params|
        params.transform_keys!(&:to_sym)

        if params.key?(:id)
          if params[:_destroy] == '1'
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
      puts(e)
      false
    end
  end

  concerning :ConferenceDaysBuilder do
    attr_accessor :conference_days

    def conference_days
      @conference_days ||= @conference.conference_days
    end

    def conference_days_attributes=(attributes)
      @conference_days ||= []
      attributes.each do |_i, params|
        params.transform_keys!(&:to_sym)

        if params.key?(:id)
          if params[:_destroy] == '1'
            link = @conference.conference_days.find(params[:id])
            link.destroy
          else
            params.delete(:_destroy)
            link = @conference.conference_days.find(params[:id])
            link.update(params)
          end
        else
          params.delete(:_destroy)
          day = ConferenceDay.new(params.merge(conference_id: conference.id))
          day.save!
          @conference_days.push(day)
        end
      end
    rescue => e
      puts(e)
      false
    end
  end

  def initialize(attributes = nil, conference: Conference.new)
    @conference = conference
    attributes = default_attributes.merge(attributes || {})
    super(attributes)
  end

  def conference
    @conference
  end

  def save
    return if invalid?

    ActiveRecord::Base.transaction do
      conference.update!(conference_status:, rehearsal_mode:, cfp_result_visible:, speaker_entry:, attendee_entry:, show_timetable:, show_sponsors:, capacity:, brief:, privacy_policy:, privacy_policy_for_speaker:)
    end
  rescue => e
    puts(e)
    false
  end

  def to_model
    conference
  end

  def load
    @links = @conference.links
    @conference_days = @conference.conference_days
  end

  attr_reader :conference

  private

  def default_attributes
    {
      conference_status: conference.conference_status,
      rehearsal_mode: conference.rehearsal_mode,
      cfp_result_visible: conference.cfp_result_visible,
      speaker_entry: conference.speaker_entry,
      attendee_entry: conference.attendee_entry,
      show_timetable: conference.show_timetable,
      show_sponsors: conference.show_sponsors,
      links:,
      capacity: conference.capacity,
      conference_days:,
      brief: conference.brief,
      privacy_policy: conference.privacy_policy,
      privacy_policy_for_speaker: conference.privacy_policy_for_speaker
    }
  end
end
