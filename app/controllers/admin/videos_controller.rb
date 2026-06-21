class Admin::VideosController < ApplicationController
  include SecuredAdmin

  def index
    @talks = @conference.talks
  end

  def upload_to_youtube
    video = Video.find(params[:id])
    UploadArchiveToYoutubeJob.perform_later(video)
    redirect_back(
      fallback_location: admin_videos_path(event: @conference.abbr),
      notice: "#{video.talk.title} のYouTubeアップロードを開始しました"
    )
  end
end
