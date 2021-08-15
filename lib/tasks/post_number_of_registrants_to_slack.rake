require 'slack/incoming/webhooks'

namespace :util do
  desc "post_number_of_registrants_to_slack"
  task post_number_of_registrants_to_slack: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    url = ENV['SLACK_WEBHOOK_URL']
    abbr = ENV['CONFERENCE_ABBR']
    slack = Slack::Incoming::Webhooks.new(url)
    conference = Conference.find_by(abbr: abbr)
    slack.username = "#{conference.abbr.upcase} 参加者速報"
    body = ''

    ActiveRecord::Base.transaction do
      begin
        conference.profiles.size
        stats = StatsOfRegistrant.new(conference_id: conference.id, number_of_registrants: conference.profiles.size)
        stats.save!

        yesterday_stats = StatsOfRegistrant.where('created_at < ?', 1.days.ago).first

        body = []
        body << "#{stats.created_at.strftime("%Y-%m-%d %H:%M")} 時点の参加者登録数は #{stats.number_of_registrants} 人です！"
        body << "前日より #{stats.number_of_registrants - yesterday_stats.number_of_registrants} 人増えました！" if yesterday_stats
      rescue => e
        puts e
      end
    end

    slack.post body.join("\n") unless body.empty?
  end
end
