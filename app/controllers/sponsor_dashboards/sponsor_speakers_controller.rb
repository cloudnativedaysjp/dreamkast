class SponsorDashboards::SponsorSpeakersController < ApplicationController
  include SecuredSponsor

  skip_before_action :logged_in_using_omniauth?, only: [:new]

  def index
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id]) if params[:sponsor_id]
    @sponsor_speakers = @sponsor.speakers
  end

  # GET /:event/speaker_dashboards/:sponsor_id/speakers/new
  def new
    @sponsor = Sponsor.find(params[:sponsor_id])
    @speaker = Speaker.new
  end

  # GET /:event/speaker_dashboard/:sponsor_id/speakers/:id/edit
  def edit
    @sponsor = Sponsor.find(params[:sponsor_id]) if params[:sponsor_id]
    
    @speaker = Speaker.find_by(conference_id: @conference.id, id: params[:id])
    # authorize(@speaker)
  end

  # POST /:event/speaker_dashboard/:sponsor_id/speakers
  def create
    @sponsor = Sponsor.find(params[:sponsor_id])

    @speaker = Speaker.new(speaker_params)
    @speaker.conference = conference
    @speaker.sponsor = @sponsor
    @speaker.sub = current_user[:extra][:raw_info][:sub]
    @speaker.email = current_user[:info][:email]

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
    @sponsor = Sponsor.find(params[:sponsor_id])
    @speaker = Speaker.find(params[:id])

    if @speaker.update(speaker_params)
      flash.now[:notice] = 'スポンサー登壇者を更新しました'
    else
      flash.now[:alert] = 'スポンサー登壇者の更新に失敗しました'
      render(:edit, status: :unprocessable_entity)
    end
  end
  
  # DELETE /:event/sponsor_dashboards/:sponsor_id/speakers/:id
  def destroy
    @sponsor = Sponsor.find(params[:sponsor_id])
    @speaker = Speaker.find(params[:id])
    
    # スポンサーセッションと紐付いているかチェック
    if @speaker.talks.present?
      flash.now[:alert] = 'スポンサーセッションと紐付いているため削除できません'
      return
    end
    
    if @speaker.destroy
      flash.now[:notice] = 'スポンサー登壇者を削除しました'
    else
      flash.now[:alert] = 'スポンサー登壇者の削除に失敗しました'
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
