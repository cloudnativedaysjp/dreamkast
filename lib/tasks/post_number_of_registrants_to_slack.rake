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
    channels = []
    client.conversations_list(exclude_archived: true) do |resp|
      channels.concat(resp.channels)
    end
    conferences = Conference.unarchived

    conferences.each do |conference|
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
          body << "オンライン参加: #{stats.online_attendees}人 (#{stats.online_attendees - yesterday_stats.online_attendees})"
          body << "現地参加: #{stats.offline_attendees}人 (#{stats.offline_attendees - yesterday_stats.offline_attendees})"
          if conference.abbr == 'cndt2021'
            body << '登録者数目標: 4000人'
            body << "達成率: #{(stats.number_of_registrants.to_f / 4000 * 100).round}%"
          end
          body << "前日より #{stats.number_of_registrants - yesterday_stats.number_of_registrants} 人増えました！" if yesterday_stats
        rescue => e
          puts(e)
        end
      end

      if channels.any? { |c| c.name == conference.abbr }
        client.chat_postMessage(channel: "##{conference.abbr}", text: body.join("\n"), username: "#{conference.abbr.upcase} 参加者速報")
      end

      if conference.abbr == 'tyo2023'
        client.chat_postMessage(channel: '#tyo2023', text: body.join("\n"), username: "#{conference.abbr.upcase} 参加者速報")
      end
    end
  end
end
