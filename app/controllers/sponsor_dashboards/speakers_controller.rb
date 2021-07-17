class SponsorDashboards::SpeakersController < ApplicationController
  include SecuredSpeaker

  skip_before_action :logged_in_using_omniauth?, only: [:new]

  # GET /:event/speaker_dashboards/:sponsor_id/speakers/new
  def new
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id]) if params[:sponsor_id]

    if set_current_user
      if Speaker.find_by(conference_id: @conference.id, email: @current_user[:info][:email])
        redirect_to speaker_dashboard_path
      end
    end

    @speaker_form = SpeakerForm.new
    @speaker_form.load
  end

  # GET /:event/speaker_dashboard/:sponsor_id/speakers/:id/edit
  def edit
    @conference = Conference.find_by(abbr: params[:event])
    @speaker = Speaker.find_by(conference_id: @conference.id, id: params[:id])
    @sponsor = Sponsor.find(params[:sponsor_id]) if params[:sponsor_id]
    authorize @speaker

    @speaker_form = SpeakerForm.new(speaker: @speaker)
    @speaker_form.load
  end

  # POST /:event/speaker_dashboard/:sponsor_id/speakers
  def create
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id])

    @speaker_form = SpeakerForm.new(speaker_params, speaker: Speaker.new())
    @speaker_form.sub = @current_user[:extra][:raw_info][:sub]
    @speaker_form.email = @current_user[:info][:email]

    respond_to do |format|
      if r = @speaker_form.save
        r.each do |talk|
          begin
            # TODO: 非同期実行
            SpeakerMailer.cfp_registered(@conference, @speaker, talk).deliver_now
          rescue => e
            logger.error "Failed to send mail: #{e.message}"
          end
        end
        format.html { redirect_to sponsor_dashboards_path(sponsor_id: @sponsor.id), notice: 'Speaker was successfully created.' }
        format.json { render :show, status: :created, location: @speaker }
      else
        format.html { render :new }
        format.json { render json: @speaker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /:event/sponsor_dashboards/:sponsor_id/speakers/:id
  def update
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id])
    @speaker = Speaker.find(params[:id])
    authorize @speaker

    @speaker_form = SpeakerForm.new(speaker_params, speaker: @speaker, sponsor: @sponsor)
    @speaker_form.sub = @current_user[:extra][:raw_info][:sub]
    @speaker_form.email = @current_user[:info][:email]
    # @speaker_form.load
    exists_talks = @speaker.talk_ids

    respond_to do |format|
      if r = @speaker_form.save
        r.each do |talk|
          begin
            # TODO: 非同期実行
            SpeakerMailer.cfp_registered(@conference, @speaker, talk).deliver_now unless exists_talks.include?(talk.id)
          rescue => e
            logger.error "Failed to send mail: #{e.message}"
          end
        end
        format.html { redirect_to sponsor_dashboards_path(sponsor_id: @sponsor.id), notice: 'Speaker was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  private

  helper_method :speaker_url, :expected_participant_params, :execution_phases_params

  def speaker_url
    case action_name
    when 'new'
      "/#{params[:event]}/sponsor_dashboards/#{params[:sponsor_id]}/speakers"
    when 'edit', 'update'
      "/#{params[:event]}/sponsor_dashboards/#{params[:sponsor_id]}/speakers/#{params[:id]}"
    end
  end

  def pundit_user
    if @current_user
      Speaker.find_by(conference: @conference.id, email: @current_user[:info][:email])
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
                                    talks_attributes: [:id, :title, :abstract, :document_url, :conference_id, :_destroy, :talk_difficulty_id, :talk_time_id, :sponsor_session, expected_participants: [], execution_phases: []])
  end
end
