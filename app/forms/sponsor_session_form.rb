class SponsorSessionForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attr_accessor :sponsor_id
  attr_accessor :conference_id
  attr_accessor :title
  attr_accessor :abstract
  attr_accessor :talk_category_id
  attr_accessor :talk_difficulty_id
  attr_accessor :document_url
  attr_accessor :proposal_items
  attr_accessor :speaker_ids
  attr_accessor :talk_types

  delegate :persisted?, to: :sponsor_session

  validate :validate_three_conference_selection, if: -> { conference_id == 15 }

  concerning :ProposalItemsBuilder do
    attr_accessor :proposal_items

    def proposal_items
      @proposal_items ||= []
    end

    def proposal_items_attributes=(attributes)
      proposal_item_config_labels = @conference.proposal_item_configs.map(&:label).uniq
      proposal_item_params = {}
      proposal_item_config_labels.each do |label|
        proposal_item_params[label.pluralize] = attributes.delete(label.pluralize)
        sponsor_session.create_or_update_proposal_item(label, proposal_item_params[label.pluralize]) if proposal_item_params[label.pluralize].present?
      end
    end
  end

  def initialize(attributes = nil, sponsor_session: Talk.new, conference: nil)
    @sponsor_session = sponsor_session
    @conference = conference
    attributes ||= default_attributes
    super(attributes)
  end

  def save
    return if invalid?

    ActiveRecord::Base.transaction do
      if sponsor_session.new_record?
        process_new_talk
      else
        process_existing_talk
      end

      update_speakers
    end
    true
  rescue => e
    Rails.logger.error(e)
    false
  end

  def validate_three_conference_selection
    sponsor_session.valid?(:entry_form)
    sponsor_session.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end

  def process_existing_talk
    params = build_talk_params
    sponsor_session.update!(params)

    # Update talk types for existing talks
    update_talk_types
  end

  def process_new_talk
    params = build_talk_params

    # Save the talk first
    sponsor_session.update!(params)

    # Set talk types after the talk is persisted
    update_talk_types

    # Create proposal for new talk
    Proposal.create!(conference_id:, talk_id: sponsor_session.id)
  end

  def build_talk_params
    {
      sponsor_id:,
      conference_id:,
      title:,
      abstract:,
      talk_category_id:,
      talk_difficulty_id:,
      document_url:,
      show_on_timetable: true
    }
  end

  def update_talk_types
    types_to_set = talk_types || []
    types_to_set << TalkType::SPONSOR_SESSION_ID unless types_to_set.include?(TalkType::SPONSOR_SESSION_ID)
    sponsor_session.talk_types = types_to_set
  end

  def update_speakers
    return unless speaker_ids.present?

    # Remove existing speakers
    TalksSpeaker.where(talk_id: sponsor_session.id).destroy_all

    # Add selected speakers
    speaker_ids.reject(&:blank?).each do |speaker_id|
      TalksSpeaker.create!(talk_id: sponsor_session.id, speaker_id:)
    end
  end

  def to_model
    sponsor_session
  end

  def load
    @proposal_items = sponsor_session.proposal_items
  end

  private

  attr_reader :sponsor_session

  def default_attributes
    {
      sponsor_id: sponsor_session.sponsor_id,
      conference_id: sponsor_session.conference_id,
      title: sponsor_session.title,
      abstract: sponsor_session.abstract,
      talk_category_id: sponsor_session.talk_category_id,
      talk_difficulty_id: sponsor_session.talk_difficulty_id,
      document_url: sponsor_session.document_url,
      proposal_items:,
      speaker_ids: sponsor_session.talks_speakers.pluck(:speaker_id),
      talk_types: sponsor_session.talk_types.map(&:id)
    }
  end
end
