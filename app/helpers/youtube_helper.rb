require 'google/apis/youtube_v3'
require 'googleauth'

module YoutubeHelper
  YOUTUBE_UPLOAD_SCOPE = 'https://www.googleapis.com/auth/youtube.upload'.freeze

  # ENV の OAuth2 リフレッシュトークンから YouTube Data API クライアントを生成する。
  # 認証情報は他の外部連携と同様に ENV で管理する（Rails credentials は未使用）。
  def youtube_client
    authorizer = Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['YOUTUBE_CLIENT_ID'],
      client_secret: ENV['YOUTUBE_CLIENT_SECRET'],
      refresh_token: ENV['YOUTUBE_REFRESH_TOKEN'],
      scope: YOUTUBE_UPLOAD_SCOPE
    )
    service = Google::Apis::YoutubeV3::YouTubeService.new
    service.authorization = authorizer
    service
  end

  # mp4 ファイルを YouTube にアップロードし、作成された動画 ID を返す。
  # privacy_status のデフォルトは public（ENV YOUTUBE_PRIVACY_STATUS で上書き可）。
  def upload_video_to_youtube(mp4_path, snippet:, privacy_status: nil)
    video_object = Google::Apis::YoutubeV3::Video.new(
      snippet: Google::Apis::YoutubeV3::VideoSnippet.new(**snippet),
      status: Google::Apis::YoutubeV3::VideoStatus.new(
        privacy_status: privacy_status || ENV.fetch('YOUTUBE_PRIVACY_STATUS', 'public')
      )
    )

    resp = youtube_client.insert_video(
      'snippet,status',
      video_object,
      upload_source: mp4_path,
      content_type: 'video/mp4'
    )
    resp.id
  end
end
