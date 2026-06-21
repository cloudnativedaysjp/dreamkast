require 'slack/incoming/webhooks'

namespace :util do
  desc 'upload archive videos to youtube'
  task upload_archive_videos_to_youtube: :environment do
    include EnvHelper

    slack_webhook_url = ENV['SLACK_WEBHOOK_URL']
    slack = Slack::Incoming::Webhooks.new(slack_webhook_url)
    slack.username = 'アーカイブ動画YouTubeアップロード'
    slack.channel = ENV['SLACK_CHANNEL']

    Video.youtube_pending.each do |video|
      result = Youtube::ArchiveUploader.new(video).process!
      puts("Video id: #{video.id}, talk: #{video.talk_id}, result: #{result}, status: #{video.youtube_upload_status}")

      case result
      when :uploaded
        body = []
        body << 'アーカイブ動画のYouTubeアップロードが完了しました:'
        body << "Track :#{video.talk.track&.name}"
        body << "登壇者: #{video.talk.speaker_names.join("\n")}"
        body << "セッション: #{video.talk.title}"
        body << "YouTube: https://www.youtube.com/watch?v=#{video.youtube_video_id}"
        body << "アーカイブURL: https://#{fqdn}/#{video.talk.conference.abbr}/talks/#{video.talk.id}"
        slack.post(body.join("\n"))
      when :failed
        slack.post("アーカイブ動画のYouTubeアップロードに失敗しました: talk: #{video.talk.title} (#{video.youtube_upload_error})")
      end
    rescue => e
      puts(e)
    end
  end

  def fqdn
    return "dreamkast-dk-#{review_app_number}.dev.cloudnativedays.jp" if review_app?

    case env_name
    when 'production'
      'event.cloudnativedays.jp'
    when 'staging'
      'staging.dev.cloudnativedays.jp'
    else
      'localhost:8080'
    end
  end
end
