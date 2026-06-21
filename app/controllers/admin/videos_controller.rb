class Admin::VideosController < ApplicationController
  include SecuredAdmin

  def index
    @talks = @conference.talks
  end

  def upload_to_youtube
    video = Video.find(params[:id])
    # 失敗状態は定期タスクの対象外なので、手動トリガー時はリセットして再開可能にする
    video.update!(youtube_upload_status: :not_uploaded, youtube_upload_error: nil) if video.failed?
    UploadArchiveToYoutubeJob.perform_later(video)
    redirect_back(
      fallback_location: admin_videos_path(event: @conference.abbr),
      notice: "#{video.talk.title} のYouTubeアップロードを開始しました"
    )
  end
end
