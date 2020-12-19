class SpeakersController < ApplicationController
  include Secured

  before_action :set_speaker, only: [:show, :edit, :update, :destroy]
  before_action :set_profile

  # def logged_in_using_omniauth?
  #   if session[:userinfo].present?
  #     @current_user = session[:userinfo]
  #   end
  # end

  # GET /speakers
  # GET /speakers.json
  def index
    @speakers = Speaker.all
  end

  # GET /speakers/1
  # GET /speakers/1.json
  def show
    @speaker = Speaker.find_by(id: params[:id])
    render_404 unless @speaker
    authorize @speaker

    @conference = Conference.find_by(abbr: params[:event])
  end

  # GET /speakers/new
  def new
    @speaker_form = SpeakerForm.new
    @conference = Conference.find_by(abbr: params[:event])
    @speaker_form.load
  end

  # GET /speakers/1/edit
  def edit
    @speaker = Speaker.find_by(id: params[:id])
    authorize @speaker

    @speaker_form = SpeakerForm.new(speaker: @speaker)
    @speaker_form.load

    @conference = Conference.find_by(abbr: params[:event])
  end

  # POST /speakers
  # POST /speakers.json
  def create
    @conference = Conference.find_by(abbr: params[:event])

    @speaker_form = SpeakerForm.new(speaker_params, speaker: Speaker.new())
    @speaker_form.sub = @current_user[:extra][:raw_info][:sub]
    @speaker_form.email = @current_user[:info][:email]


    respond_to do |format|
      if @speaker_form.save
        format.html { redirect_to "/#{@conference.abbr}", notice: 'Speaker was successfully created.' }
        format.json { render :show, status: :created, location: @speaker }
      else
        format.html { render :new }
        format.json { render json: @speaker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /speakers/1
  # PATCH/PUT /speakers/1.json
  def update
    @speaker = Speaker.find(params[:id])
    authorize @speaker

    @speaker_form = SpeakerForm.new(speaker_params, speaker: @speaker)
    @speaker_form.load

    respond_to do |format|
      if @speaker_form.update(speaker_params)
        format.html { redirect_to speaker_path(id: @speaker.id), notice: 'Speaker was successfully updated.' }
        format.json { render :show, status: :ok, location: @speaker }
      else
        format.html { render :edit }
        format.json { render json: @speaker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /speakers/1
  # DELETE /speakers/1.json
  def destroy
    @speaker.destroy
    respond_to do |format|
      format.html { redirect_to speakers_url, notice: 'Speaker was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_speaker
    @speaker = Speaker.find(params[:id])
  end

  def set_profile
    if @current_user
      @profile = Profile.find_by(email: @current_user[:info][:email])
    end
  end

  helper_method :speaker_url

  def speaker_url
    case action_name
    when 'new'
      "/#{params[:event]}/speakers"
    when 'edit'
      "/#{params[:event]}/speakers/#{params[:id]}"
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
