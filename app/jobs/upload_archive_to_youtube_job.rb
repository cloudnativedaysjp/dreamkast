class UploadArchiveToYoutubeJob < ApplicationJob
  self.queue_adapter = :async unless Rails.env.test?

  # 管理画面からの手動トリガー用。状態を 1 ステップ進める（通常は変換開始）。
  # 変換完了〜アップロードは定期タスク util:upload_archive_videos_to_youtube が引き継ぐ。
  def perform(video)
    Youtube::ArchiveUploader.new(video).process!
  end
end
