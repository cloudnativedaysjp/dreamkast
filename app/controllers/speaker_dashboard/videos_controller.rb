class SpeakerDashboard::VideosController < ApplicationController
  include SecuredSpeaker

  skip_before_action :logged_in_using_omniauth?, only: [:new]


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
      uploaded = VideoFileUploader.upload(videos_params[:video_file], :store)
      if @video.update_attributes(video_file_data: uploaded.to_json)
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
    params.require(:video).permit(:video_file)
  end
end
