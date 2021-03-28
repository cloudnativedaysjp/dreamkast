class SpeakerDashboard::VideosController < ApplicationController
  include SecuredSpeaker

  before_action :set_conference

  # GET :event/speaker_dashboard/videos
  def new
    @talk = Talk.find(params[:talk_id])
    authorize @talk

    @video = Video.new()
  end

  # POST :event/speaker_dashboard/videos
  def create
    @talk = Talk.find(videos_params[:talk_id])
    authorize @talk

    @video = Video.new(videos_params)

    respond_to do |format|
      if @video.save
        speaker = Speaker.find_by(conference: @conference.id, email: @current_user[:info][:email])
        # TODO: 非同期化すること！！！
        begin
          SpeakerMailer.video_uploaded(speaker, @talk, @video).deliver_now
        rescue => e
          logger.error "Failed to send mail: #{e.message}"
        end

        format.html { redirect_to speaker_dashboard_path, notice: 'Speaker was successfully updated.' }
        format.json { render :show, status: :ok, location: @video }
      else
        format.html { render :edit }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET :event/speaker_dashboard/videos/:id/edit
  def edit
    @video = Video.find_by(id: params[:id])
    @talk = @video.talk
    authorize @talk
  end

  # PATCH/PUT :event/speaker_dashboard/videos/1
  def update
    @video = Video.find(params[:id])
    @talk = @video.talk
    authorize @talk

    respond_to do |format|
      if @video.update(videos_params)

        # TODO: 非同期化すること！！！
        begin
          SpeakerMailer.video_uploaded(speaker, @talk, @video).deliver_now
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

  helper_method :video_url

  def video_url
    case action_name
    when 'new'
      "/#{params[:event]}/speaker_dashboard/videos"
    when 'edit'
      "/#{params[:event]}/speaker_dashboard/videos/#{params[:id]}"
    end
  end

  def pundit_user
    if @current_user
      Speaker.find_by(conference: @conference.id, email: @current_user[:info][:email])
    end
  end

  def videos_params
    params.require(:video).permit(:talk_id, :url)
  end
end
