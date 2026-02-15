namespace :ses do
  desc 'Poll SES event SQS queue once'
  task poll: :environment do
    require Rails.root.join('lib/ses_event_poller')
    queue_url = ENV.fetch('SES_EVENT_QUEUE_URL')
    SesEventPoller.new(queue_url:).poll_once
  end
end
