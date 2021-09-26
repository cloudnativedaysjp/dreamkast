require 'slack/incoming/webhooks'

namespace :util do
  desc "post_number_of_registrants_to_slack"
  task post_number_of_registrants_to_slack: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    url = ENV['SLACK_WEBHOOK_URL']
    conferences = Conference.unarchived

    conferences.each do |conference|
      slack = Slack::Incoming::Webhooks.new(url)
      slack.username = "#{conference.abbr.upcase} 参加者速報"
      body = ''

      ActiveRecord::Base.transaction do
        begin
          stats = StatsOfRegistrant.new(conference_id: conference.id, number_of_registrants: conference.profiles.size)
          stats.save!

          yesterday_stats = StatsOfRegistrant.where("conference_id = ? AND DATE_FORMAT(created_at, '%Y-%m-%d') = ?", conference.id, 1.days.ago.to_time.strftime("%Y-%m-%d")).first

          body = []
          body << "#{stats.created_at.strftime("%Y-%m-%d %H:%M")} 時点の参加者登録数は #{stats.number_of_registrants} 人です！"
          if conference.abbr == 'cndt2021'
            body << "登録者数目標: 4000人"
            body << "達成率: #{(stats.number_of_registrants.to_f / 4000 * 100).round}%"
          end
          body << "前日より #{stats.number_of_registrants - yesterday_stats.number_of_registrants} 人増えました！" if yesterday_stats
        rescue => e
          puts e
        end
      end

      slack.post body.join("\n") unless body.empty?
    end
  end
end
