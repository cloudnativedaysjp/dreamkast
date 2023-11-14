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

    msg = <<~EOS
      以下のMediaLive Channelが作成済みのままです:

      #{channels.map { |c| "- #{c.name} (#{c.state})" }.join("\n")}
    EOS

    client = Slack::Web::Client.new
    client.chat_postMessage(channel: '#broadcast', text: msg, username: 'Dreamkast')
  end
end
