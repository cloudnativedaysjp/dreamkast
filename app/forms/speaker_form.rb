class SpeakerForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attr_accessor :name,
                :email,
                :sub,
                :profile,
                :company,
                :job_title,
                :twitter_id,
                :github_id,
                :avatar,
                :conference_id,
                :talks

  delegate :persisted?, to: :speaker

  concerning :TalksBuilder do
    attr_accessor :talks

    def talks
      @talks ||= []
    end

    def talks_attributes=(attributes)
      @talks ||= []
      @destroy_talks ||= []
      attributes.each do |_i, params|
        if params.key?(:id)
          if params[:_destroy] == "1"
            @destroy_talks << @speaker.talks.find(params[:id])
          else
            @talks << @speaker.talks.find(params[:id])
          end
        else
          params.delete(:_destroy)
          @talks << Talk.new(params)
        end
      end
    rescue => e
      puts e
      false
    end
  end

  def initialize(attributes = nil, speaker: Speaker.new)
    @speaker = speaker
    attributes ||= default_attributes
    super(attributes)
  end

  def speaker
    @speaker
  end

  def save
    return if invalid?

    ActiveRecord::Base.transaction do
      puts "conference_id #{conference_id}"
      speaker.update!(name: name, profile: profile, company: company, job_title: job_title, twitter_id: twitter_id, github_id: github_id, avatar: avatar, conference_id: conference_id)
      @talks.each do |talk|
        talk.save!
        talk_speaker = TalksSpeaker.new(talk_id: talk.id, speaker_id: speaker.id)
        talk_speaker.save!
      end
    end
  rescue => e
    puts "faild to save: #{e}"
    false
  end

  def to_model
    speaker
  end

  def load
    @talks = @speaker.talks
  end

  attr_reader :speaker

  private

  def default_attributes
    {
      name: speaker.name,
      email: speaker.email,
      sub: speaker.sub,
      profile: speaker.profile,
      company: speaker.company,
      job_title: speaker.job_title,
      twitter_id: speaker.twitter_id,
      github_id: speaker.github_id,
      avatar: speaker.avatar_data,
      talks: talks
    }
  end
end