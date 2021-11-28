require "slack/incoming/webhooks"
require "date"

namespace :util do
  desc "post_left_idea_issues_to_slack"
  task post_left_idea_issues_to_slack: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    url = ENV["SLACK_WEBHOOK_URL"]
    slack = Slack::Incoming::Webhooks.new(url)
    slack.channel = ENV["SLACK_CHANNEL_NAME"]

    token = ENV["GITHUB_PERSONAL_ACCESS_TOKEN"]
    client = Octokit::Client.new(access_token: token)
    client.auto_paginate = true

    created = Date.today.prev_day(5).to_s
    payload = "作成後 5 日以上アサインが決まっていない idea issueがあります〜〜\n担当チーム、担当者をアサインしたらideaラベルを外してね。"
    attachments = []

    result = client.search_issues("repo:cloudnativedaysjp/cndt2021 is:issue is:open created:<#{created} label:idea no:assignee")
    result.items.each do |issue|
      attachments << {
        title: "#{issue.number} #{issue.title}",
        title_link: issue.url,
        color: "#7CD197"
      }
    end

    slack.post(payload, attachments: attachments)
  end
end
