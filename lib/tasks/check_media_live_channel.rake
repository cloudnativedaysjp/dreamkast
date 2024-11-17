require 'slack/incoming/webhooks'

namespace :util do
  desc 'check_media_live_channel'
  task check_media_live_channel: :environment do
    include MediaLiveHelper
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    Slack.configure do |config|
      config.token = ENV['SLACK_TOKEN']
    end

    msg = ''


    conferences = Conference.merge(Conference.where(conference_status: Conference::STATUS_OPENED)).or(Conference.where(conference_status: Conference::STATUS_CLOSED))
    conferences.each do |conference|
      unarchived_talks = conference.talks.select do |talk|
        talk.abstract != 'intermission' && talk.live? && talk.video&.video_id&.empty?
      end

      unless unarchived_talks.empty?
        msg += <<~EOS
          [#{conference.abbr.upcase}] 以下のセッションがアーカイブされていません:

          #{unarchived_talks.map { |t| "- #{t.title} (#{t.start_time})" }.join("\n")}

        EOS
      end
    end

    channels = []
    next_token = nil
    loop do
      resp = media_live_client.list_channels(next_token:)
      channels.concat(resp.channels)
      break unless resp.next_token

      next_token = resp.next_token
    end

    channels.each do |channel|
      puts channel.name
    end

    unless channels.empty?
      msg += <<~EOS
        以下のMediaLive Channelが作成済みのままです:

        #{channels.map { |c| "- #{c.name} (#{c.state})" }.join("\n")}
      EOS
    end

    if msg != ''
      puts msg
      client = Slack::Web::Client.new
      client.chat_postMessage(channel: '#broadcast', text: msg, username: 'Dreamkast')
    end
  end
end
