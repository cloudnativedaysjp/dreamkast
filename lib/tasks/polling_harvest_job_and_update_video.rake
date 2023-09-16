require 'slack/incoming/webhooks'

namespace :util do
  desc 'polling harvest job and update video'
  task polling_harvest_job_and_update_video: :environment do
    include EnvHelper
    include MediaPackageHelper

    slack_webhook_url = ENV['SLACK_WEBHOOK_URL']
    slack = Slack::Incoming::Webhooks.new(slack_webhook_url)
    slack.username = 'アーカイブ動画作成チェック'
    slack.channel = ENV['SLACK_CHANNEL']

    MediaPackageHarvestJob.where(status: 'IN_PROGRESS').each do |harvest_job|
      resp = harvest_job.job
      harvest_job.update!(status: resp.status)

      puts("Harvest Job: id: #{resp.id}, status: #{resp.status}")
      if resp.status == 'SUCCEEDED'
        puts("Update video id: #{harvest_job.video_url}")
        harvest_job.talk.video.update!(video_id: harvest_job.video_url)

        body = []
        body << 'アーカイブの作成が完了しました:'
        body << "Track :#{harvest_job.talk.track.name}"
        body << "登壇者: #{harvest_job.talk.speaker_names.join("\n")}"
        body << "セッション: #{harvest_job.talk.title}"
        body << "アーカイブURL: https://#{fqdn}/#{harvest_job.conference.abbr}/talks/#{harvest_job.talk.id}"

        slack.post(body.join("\n")) unless body.empty?
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
