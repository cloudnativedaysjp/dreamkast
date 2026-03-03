class SpeakerDashboard::SpeakersController < ApplicationController
  include SecuredSpeaker

  skip_before_action :logged_in_using_omniauth?, only: [:new, :guidance]
  before_action :prepare_create, only: [:new]

  # GET :event/speaker_dashboard/speakers/guidance
  def guidance
    return redirect_to(speakers_entry_path) if from_auth0?(params)
    @conference = Conference.find_by(abbr: params[:event])
  end

  # GET :event/speaker_dashboard/speakers/new
  def new
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id]) if params[:sponsor_id]

    if current_user && current_user_model
      if Speaker.find_by(conference_id: @conference.id, user_id: current_user_model.id)
        redirect_to(speaker_dashboard_path)
      end
    end

    @speaker_form = SpeakerForm.new
    @speaker_form.load
  end

  # GET :event/speaker_dashboard/speakers/:id/edit
  def edit
    @conference = Conference.find_by(abbr: params[:event])
    @speaker = Speaker.find_by(conference_id: @conference.id, id: params[:id])
    @sponsor = Sponsor.find(params[:sponsor_id]) if params[:sponsor_id]
    authorize(@speaker)

    @speaker_form = SpeakerForm.new(speaker: @speaker, conference: @conference)
    @speaker_form.load
  end

  # POST :event/speaker_dashboard/speakers
  # POST :event/speaker_dashboard/speakers.json
  def create
    @conference = Conference.find_by(abbr: params[:event])

    @speaker_form = SpeakerForm.new(speaker_params, speaker: Speaker.new, conference: @conference)
    @speaker_form.sub = current_user_model&.sub
    @speaker_form.email = current_user[:info][:email]

    respond_to do |format|
      if r = @speaker_form.save
        @speaker = @speaker_form.speaker
        r.each do |talk|
          SpeakerMailer.cfp_registered(@conference, @speaker, talk).deliver_later
        end
        flash.now[:notice] = 'スピーカーもしくはプロポーザルの作成・更新に成功しました。'
        format.html { redirect_to("/#{@conference.abbr}/speaker_dashboard") }
        format.json { render(:show, status: :created, location: @speaker) }
      else
        format.html { render(:new) }
        format.json { render(json: @speaker.errors, status: :unprocessable_entity) }
      end
    end
  end

  # PATCH/PUT :event/speaker_dashboard/speakers/1
  # PATCH/PUT :event/speaker_dashboard/speakers/1.json
  def update
    @conference = Conference.find_by(abbr: params[:event])
    @speaker = Speaker.find(params[:id])
    authorize(@speaker)

    @speaker_form = SpeakerForm.new(speaker_params, speaker: @speaker, conference: @conference)
    @speaker_form.sub = current_user_model&.sub
    @speaker_form.email = current_user[:info][:email]
    # @speaker_form.load
    exists_talks = @speaker.talk_ids

    respond_to do |format|
      if r = @speaker_form.save
        r.each do |talk|
          SpeakerMailer.cfp_registered(@conference, @speaker, talk).deliver_later unless exists_talks.include?(talk.id)
        end
        format.html { redirect_to(speaker_dashboard_path, notice: 'Speaker was successfully updated.') }
        format.json { render(:show, status: :ok, location: @speaker) }
      else
        format.html { render(:edit) }
        format.json { render(json: @speaker_form.errors, status: :unprocessable_entity) }
      end
    end
  end

  private

  helper_method :speaker_url, :expected_participant_params, :execution_phases_params

  def from_auth0?(params)
    params[:state].present?
  end

  def speaker_url
    case action_name
    when 'new', 'create'
      "/#{params[:event]}/speaker_dashboard/speakers"
    when 'edit', 'update'
      "/#{params[:event]}/speaker_dashboard/speakers/#{params[:id]}"
    end
  end

  def pundit_user
    if current_user && current_user_model
      Speaker.find_by(conference_id: @conference.id, user_id: current_user_model.id)
    end
  end

  def expected_participant_params
    @conference.proposal_item_configs.where(label: 'expected_participant')
  end

  def execution_phases_params
    @conference.proposal_item_configs.where(label: 'execution_phase')
  end

  # Only allow a list of trusted parameters through.
  def speaker_params
    params.require(:speaker).permit(:name,
                                    :name_mother_tongue,
                                    :sub,
                                    :email,
                                    :profile,
                                    :company,
                                    :job_title,
                                    :twitter_id,
                                    :github_id,
                                    :avatar,
                                    :conference_id,
                                    :additional_documents,
                                    talks_attributes:)
  end

  def talks_attributes
    attr = [:id, :title, :abstract, :document_url, :conference_id, :_destroy, :talk_category_id, :talk_difficulty_id, :talk_time_id, :sponsor_id, { talk_types: [] }]
    h = {}
    @conference.proposal_item_configs.map(&:label).uniq.each do |label|
      conf = @conference.proposal_item_configs.find_by(label:)
      if conf.class.to_s == 'ProposalItemConfigCheckBox'
        h[conf.label.pluralize.to_sym] = []
      elsif conf.class.to_s == 'ProposalItemConfigRadioButton'
        attr << conf.label.pluralize.to_sym
      end
    end
    attr.append(h)
  end
end
