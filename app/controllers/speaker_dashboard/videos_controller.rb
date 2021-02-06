class SpeakerDashboard::VideosController < ApplicationController
  include SecuredSpeaker

  # GET :event/speaker_dashboard/videos
  def new
    @conference = Conference.find_by(abbr: params[:event])
    @talk = Talk.find(params[:talk_id])
    @speaker = pundit_user
    authorize @speaker

    @video = Video.new()
    unless @talk.speakers.map(&:id).include?(@speaker.id)
      raise Forbidden
    end

  end

  # POST :event/speaker_dashboard/videos
  def create
    @conference = Conference.find_by(abbr: params[:event])
    @talk = Talk.find(videos_params[:talk_id])
    @video = Video.new(videos_params)
    @speaker = pundit_user
    authorize @speaker

    respond_to do |format|
      if @video.save
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
    @conference = Conference.find_by(abbr: params[:event])
    @video = Video.find_by(id: params[:id])
    @talk = @video.talk
    @speaker = pundit_user
    authorize @speaker
  end

  # PATCH/PUT :event/speaker_dashboard/videos/1
  def update
    @conference = Conference.find_by(abbr: params[:event])
    @video = Video.find(params[:id])
    @speaker = pundit_user
    authorize @speaker

    respond_to do |format|
      old_file = @video.video_file if @video.video_file_data != ""
      if @video.update_attributes(video_file_data: videos_params[:video_file_data])
        old_file.delete if old_file
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
    params.require(:video).permit(:talk_id, :video_file_data)
  end
end
