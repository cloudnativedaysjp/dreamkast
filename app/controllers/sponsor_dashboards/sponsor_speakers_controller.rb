class SponsorDashboards::SponsorSpeakersController < ApplicationController
  include SecuredSponsor

  skip_before_action :logged_in_using_omniauth?, only: [:new]

  def index
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id]) if params[:sponsor_id]
    @sponsor_speakers = @sponsor.talks.map(&:speakers).flatten.uniq
  end

  # GET /:event/speaker_dashboards/:sponsor_id/speakers/new
  def new
    @sponsor = Sponsor.find(params[:sponsor_id])
    @speaker = Speaker.new
  end

  # GET /:event/speaker_dashboard/:sponsor_id/speakers/:id/edit
  def edit
    @conference = Conference.find_by(abbr: params[:event])
    @speaker = Speaker.find_by(conference_id: @conference.id, id: params[:id])
    @sponsor = Sponsor.find(params[:sponsor_id]) if params[:sponsor_id]
    authorize(@speaker)

    @speaker_form = SpeakerForm.new(speaker: @speaker)
    @speaker_form.load
  end

  # POST /:event/speaker_dashboard/:sponsor_id/speakers
  def create
    p 'CREATE===================================================================='
    @sponsor = Sponsor.find(params[:sponsor_id])

    @speaker = Speaker.new(speaker_params)
    @speaker.conference = conference
    @speaker.sub = current_user[:extra][:raw_info][:sub]
    @speaker.email = current_user[:info][:email]

    p @speaker

    if @speaker.save
      flash.now[:notice] = 'スポンサー登壇者を登録しました'
    else
      flash.now[:alert] = 'スポンサー登壇者の登録に失敗しました'
      puts @speaker.errors.full_messages.join(', ')
      render(:new, status: :unprocessable_entity)
    end
  end

  # PATCH/PUT /:event/sponsor_dashboards/:sponsor_id/speakers/:id
  def update
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id])
    @speaker = Speaker.find(params[:id])
    authorize(@speaker)

    @speaker_form = SpeakerForm.new(speaker_params, speaker: @speaker, sponsor: @sponsor, conference: @conference)
    @speaker_form.sub = current_user[:extra][:raw_info][:sub]
    @speaker_form.email = current_user[:info][:email]
    # @speaker_form.load
    exists_talks = @speaker.talk_ids

    respond_to do |format|
      if (r = @speaker_form.save)
        r.each do |talk|
          SpeakerMailer.cfp_registered(@conference, @speaker, talk).deliver_later unless exists_talks.include?(talk.id)
        end
        format.html { redirect_to(sponsor_dashboards_path(sponsor_id: @sponsor.id), notice: 'Speaker was successfully updated.') }
      else
        format.html { render(:edit) }
      end
    end
  end

  private

  helper_method :speaker_url, :expected_participant_params, :execution_phases_params, :turbo_stream_flash

  def speaker_url
    case action_name
    when 'new'
      "/#{params[:event]}/sponsor_dashboards/#{params[:sponsor_id]}/speakers"
    when 'edit', 'update'
      "/#{params[:event]}/sponsor_dashboards/#{params[:sponsor_id]}/speakers/#{params[:id]}"
    end
  end

  def pundit_user
    if current_user
      Speaker.find_by(conference: @conference.id, email: current_user[:info][:email])
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
                                    :sponsor_id,
                                    :avatar,
                                    :conference_id,
                                    :additional_documents
                                    )
  end

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
