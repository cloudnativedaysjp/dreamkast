class SpeakerForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include AvatarUploader::Attachment(:avatar)

  attr_accessor :name
  attr_accessor :name_mother_tongue
  attr_accessor :email
  attr_accessor :sub
  attr_accessor :profile
  attr_accessor :company
  attr_accessor :job_title
  attr_accessor :twitter_id
  attr_accessor :github_id
  attr_accessor :avatar
  attr_accessor :conference_id
  attr_accessor :additional_documents
  attr_accessor :talks

  delegate :persisted?, to: :speaker

  concerning :TalksBuilder do
    attr_accessor :talks

    def talks
      @talks || []
    end

    def talks_attributes=(attributes)
      @talks ||= []
      @destroy_talks ||= []
      attributes.each do |_i, params|
        next if params.nil?

        params = params.symbolize_keys
        talk_attributes = params.delete(:talk_attributes) || []

        if params.key?(:id)
          process_existing_talk(params, talk_attributes)
        else
          process_new_talk(params, talk_attributes)
        end
      end
    rescue => e
      puts(e)
      false
    end

    private

    def process_existing_talk(params, talk_attributes)
      if params[:_destroy] == '1'
        @destroy_talks << @speaker.talks.find(params[:id])
      else
        update_existing_talk(params, talk_attributes)
      end
    end

    def process_new_talk(params, talk_attributes)
      return if params[:_destroy] == '1'

      params.delete(:_destroy)
      params[:show_on_timetable] = true
      params[:video_published] = true

      proposal_item_params = extract_proposal_items(params)

      t = Talk.new(params)
      t.conference = @conference if @conference

      set_proposal_items(t, proposal_item_params)

      # Store talk_attributes to be set after talk is saved
      # (Unlike proposal_items which use build, talk_attributes require the talk to be persisted first)
      t.instance_variable_set(:@pending_talk_attributes, talk_attributes) if talk_attributes.present?
      @talks << t
    end

    def update_existing_talk(params, talk_attributes)
      params.delete(:_destroy)
      talk = @speaker.talks.find(params[:id])

      proposal_item_params = extract_proposal_items(params)
      set_proposal_items(talk, proposal_item_params)

      talk.create_or_update_talk_attributes(talk_attributes) if talk_attributes.present?
      talk.update(params)
      @talks << talk
    end

    def extract_proposal_items(params)
      proposal_item_params = {}
      proposal_item_config_labels.each do |label|
        pluralized_label = label.pluralize
        symbol_key = pluralized_label.to_sym
        proposal_item_params[pluralized_label] = params.delete(symbol_key)
      end
      proposal_item_params
    end

    def set_proposal_items(talk, proposal_item_params)
      proposal_item_config_labels.each do |label|
        value = proposal_item_params[label.pluralize]
        talk.create_or_update_proposal_item(label, value) if value.present?
      end
    end

    def proposal_item_config_labels
      @proposal_item_config_labels ||= @conference.proposal_item_configs.map(&:label).uniq
    end
  end

  def initialize(attributes = nil, speaker: Speaker.new, sponsor: nil, conference: nil)
    @speaker = speaker
    @sponsor = sponsor
    @conference = conference
    @talks ||= []
    @destroy_talks ||= []
    attributes ||= default_attributes
    super(attributes)
  end

  def speaker
    @speaker
  end

  def save
    return if invalid?

    ActiveRecord::Base.transaction do
      speaker.update!(name:, name_mother_tongue:, profile:, company:, job_title:, twitter_id:, github_id:, avatar:, conference_id:,
                      sub:, email:, additional_documents:)
      @destroy_talks.each do |talk|
        proposal = talk.proposal
        talk_speaker = TalksSpeaker.new(talk_id: talk.id, speaker_id: speaker.id)
        talk.destroy!
        talk_speaker.destroy!
        proposal.destroy! if proposal
      end
      @talks.each do |talk|
        if talk.persisted?
          talk.save!(context: :entry_form)
        else
          talk.save!(context: :entry_form)

          # Set talk attributes for new talks (same pattern as proposal_items)
          pending_attributes = talk.instance_variable_get(:@pending_talk_attributes)
          talk.create_or_update_talk_attributes(pending_attributes) if pending_attributes.present?
          talk_speaker = TalksSpeaker.new(talk_id: talk.id, speaker_id: speaker.id)
          talk_speaker.save!

          proposal = Proposal.new(conference_id:, talk_id: talk.id)
          proposal.save!
        end
      end
    end
  rescue => e
    puts("failed to save: #{e}")
    false
  end

  def to_model
    speaker
  end

  def load
    @talks = @speaker.talks.to_a
    # If no talks exist, create a default one for the form
    if @talks.empty? && @conference
      @talks = [Talk.new(conference: @conference)]
    end
  end

  attr_reader :speaker


  def default_attributes
    {
      name: speaker.name,
      name_mother_tongue: speaker.name_mother_tongue,
      email: speaker.email,
      sub: speaker.sub,
      profile: speaker.profile,
      company: speaker.company,
      job_title: speaker.job_title,
      twitter_id: speaker.twitter_id,
      github_id: speaker.github_id,
      avatar: speaker.avatar_data,
      additional_documents: speaker.additional_documents
    }
  end
end
