class SpeakerDashboard::SpeakersController < ApplicationController
  include SecuredSpeaker

  skip_before_action :logged_in_using_omniauth?, only: [:new]

  # def logged_in_using_omniauth?
  #   if session[:userinfo].present?
  #     @current_user = session[:userinfo]
  #   end

  # GET :event/speaker_dashboard/speakers/new
  def new
    if @current_user
      if Speaker.find_by(email: @current_user[:info][:email])
        redirect_to speaker_dashboard_path
      end
    end

    @speaker_form = SpeakerForm.new
    @conference = Conference.find_by(abbr: params[:event])
    @speaker_form.load
  end

  # GET :event/speaker_dashboard/speakers/:id/edit
  def edit
    @conference = Conference.find_by(abbr: params[:event])
    @speaker = Speaker.find_by(conference_id: @conference.id, id: params[:id])
    authorize @speaker

    @speaker_form = SpeakerForm.new(speaker: @speaker)
    @speaker_form.load

  end

  # POST :event/speaker_dashboard/speakers
  # POST :event/speaker_dashboard/speakers.json
  def create
    @conference = Conference.find_by(abbr: params[:event])

    @speaker_form = SpeakerForm.new(speaker_params, speaker: Speaker.new())
    @speaker_form.sub = @current_user[:extra][:raw_info][:sub]
    @speaker_form.email = @current_user[:info][:email]

    respond_to do |format|
      if @speaker_form.save
        format.html { redirect_to "/#{@conference.abbr}/speaker_dashboard", notice: 'Speaker was successfully created.' }
        format.json { render :show, status: :created, location: @speaker }
      else
        format.html { render :new }
        format.json { render json: @speaker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT :event/speaker_dashboard/speakers/1
  # PATCH/PUT :event/speaker_dashboard/speakers/1.json
  def update
    @conference = Conference.find_by(abbr: params[:event])
    @speaker = Speaker.find(params[:id])
    authorize @speaker

    @speaker_form = SpeakerForm.new(speaker_params, speaker: @speaker)
    @speaker_form.sub = @current_user[:extra][:raw_info][:sub]
    @speaker_form.email = @current_user[:info][:email]
    # @speaker_form.load

    respond_to do |format|
      if @speaker_form.save
        format.html { redirect_to speaker_dashboard_path, notice: 'Speaker was successfully updated.' }
        format.json { render :show, status: :ok, location: @speaker }
      else
        format.html { render :edit }
        format.json { render json: @speaker_form.speaker.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  helper_method :speaker_url

  def speaker_url
    case action_name
    when 'new'
      "/#{params[:event]}/speaker_dashboard/speakers"
    when 'edit'
      "/#{params[:event]}/speaker_dashboard/speakers/#{params[:id]}"
    end
  end

  def pundit_user
    if @current_user
      Speaker.find_by(email: @current_user[:info][:email])
    end
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
                                    talks_attributes: [:id, :title, :abstract, :conference_id, :_destroy])
  end
end
