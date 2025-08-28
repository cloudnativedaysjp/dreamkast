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
      params = { sponsor_id:, conference_id:, title:, abstract:, talk_category_id:, talk_difficulty_id:, document_url:, show_on_timetable: true }

      was_new_record = sponsor_session.new_record?
      sponsor_session.update!(params)

      # Set talk types - always include sponsor type for sponsor sessions
      types_to_set = talk_types || []
      types_to_set << 'sponsor' unless types_to_set.include?('sponsor')
      sponsor_session.create_or_update_talk_types(types_to_set)

      if was_new_record
        Proposal.create!(conference_id:, talk_id: sponsor_session.id)
      end

      # Update speakers
      if speaker_ids.present?
        # Remove existing speakers
        TalksSpeaker.where(talk_id: sponsor_session.id).destroy_all

        # Add selected speakers
        speaker_ids.reject(&:blank?).each do |speaker_id|
          TalksSpeaker.create!(talk_id: sponsor_session.id, speaker_id:)
        end
      end
    end
    true
  rescue => e
    Rails.logger.error(e)
    false
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
      talk_types: sponsor_session.talk_types.pluck(:id)
    }
  end
end
