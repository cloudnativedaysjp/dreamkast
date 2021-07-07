class SpeakerDashboard::VideoRegistrationsController < ApplicationController
  include SecuredSpeaker

  before_action :set_conference

  # GET :event/speaker_dashboard/video_registrations
  def new
    @talk = Talk.find(params[:talk_id])
    authorize @talk

    @video_registration = VideoRegistration.new()
  end

  # POST :event/speaker_dashboard/video_registrations
  def create
    @talk = Talk.find(video_registrations_params[:talk_id])
    authorize @talk

    @video_registration = VideoRegistration.new(video_registrations_params.merge(status: 1))

    respond_to do |format|
      if @video_registration.save
        # speaker = Speaker.find_by(conference: @conference.id, email: @current_user[:info][:email])
        # TODO: 非同期化すること！！！
        # begin
        #   SpeakerMailer.video_uploaded(speaker, @talk, @video_registration).deliver_now
        # rescue => e
        #   logger.error "Failed to send mail: #{e.message}"
        # end

        format.html { redirect_to speaker_dashboard_path, notice: 'Speaker was successfully updated.' }
        format.json { render :show, status: :ok, location: @video_registration }
      else
        format.html { render :edit }
        format.json { render json: @video_registration.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET :event/speaker_dashboard/videos/:id/edit
  def edit
    @video_registration = VideoRegistration.find_by(id: params[:id])
    @talk = @video_registration.talk
    authorize @talk
  end

  # PATCH/PUT :event/speaker_dashboard/videos/1
  def update
    @video_registration = VideoRegistration.find(params[:id])
    @talk = @video_registration.talk
    authorize @talk

    respond_to do |format|
      if @video_registration.update(video_registrations_params)

        begin
          SpeakerMailer.video_uploaded(speaker, @talk, @video_registration)
        rescue => e
          logger.error "Failed to send mail: #{e.message}"
        end

        format.html { redirect_to speaker_dashboard_path, notice: 'Speaker was successfully updated.' }
        format.json { render :show, status: :ok, location: @talk }
      else
        format.html { render :edit }
        format.json { render json: @talk.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  helper_method :video_registration_url

  def video_registration_url
    case action_name
    when 'new'
      "/#{params[:event]}/speaker_dashboard/video_registrations"
    when 'edit'
      "/#{params[:event]}/speaker_dashboard/video_registrations/#{params[:id]}"
    end
  end

  def pundit_user
    if @current_user
      Speaker.find_by(conference: @conference.id, email: @current_user[:info][:email])
    end
  end

  def video_registrations_params
    params.require(:video_registration).permit(:talk_id, :url, :status)
  end
end
