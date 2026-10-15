require 'slack/incoming/webhooks'

namespace :util do
  desc 'post_number_of_registrants_to_slack'
  task post_number_of_registrants_to_slack: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    Slack.configure do |config|
      config.token = ENV['SLACK_TOKEN']
    end

    client = Slack::Web::Client.new

    # SLACK_CHANNEL（チャンネル名 "#foo" またはチャンネル ID）が指定されていれば全カンファレンスの速報をそのチャンネルに投稿する。
    # 未指定の場合はカンファレンスの abbr と同名のチャンネルが存在するときのみ投稿する。
    specified_channel = ENV['SLACK_CHANNEL'].to_s.strip.presence
    channels = []
    unless specified_channel
      client.conversations_list(exclude_archived: true) do |resp|
        channels.concat(resp.channels)
      end
    end
    conferences = Conference.unarchived

    conferences.each do |conference|
      puts "conference: #{conference.abbr}"
      body = ''

      ActiveRecord::Base.transaction do
        begin
          online_attendees = Profile.where(conference_id: conference.id, participation: 'online').count
          offline_attendees = Profile.where(conference_id: conference.id, participation: 'offline').count

          stats = StatsOfRegistrant.new(conference_id: conference.id, offline_attendees:, online_attendees:)
          stats.save!

          yesterday_stats = StatsOfRegistrant.where("conference_id = ? AND DATE_FORMAT(created_at, '%Y-%m-%d') = ?", conference.id, 1.days.ago.to_time.strftime('%Y-%m-%d')).first

          body = []
          body << "#{stats.created_at.strftime("%Y-%m-%d %H:%M")} 時点の参加者登録数は #{stats.online_attendees + stats.offline_attendees} 人です！"
          body << "オンライン参加: #{stats.online_attendees}人 (+#{stats.online_attendees - yesterday_stats.online_attendees}人)"
          body << "現地参加: #{stats.offline_attendees}人 (+#{stats.offline_attendees - yesterday_stats.offline_attendees}人)"
          body << "前日より #{stats.number_of_registrants - yesterday_stats.number_of_registrants} 人増えました！" if yesterday_stats
        rescue => e
          puts(e)
        end
      end

      channel = specified_channel || ("##{conference.abbr}" if channels.any? { |c| c.name == conference.abbr })
      if channel
        puts "channel: #{channel} username: #{conference.abbr.upcase} 参加者速報 text: #{body.join("\n")}"
        client.chat_postMessage(channel:, text: body.join("\n"), username: "#{conference.abbr.upcase} 参加者速報")
      end
    end
  end
end
