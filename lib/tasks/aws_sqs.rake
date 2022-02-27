namespace :aws_sqs do
  desc 'create review_app linked sqs'
  task create_sqs: :environment do
    include EnvHelper

    exit unless review_app?

    cli = Aws::SQS::Client.new(region: 'ap-northeast-1')
    queue_name = "review_app_#{review_app_number}" + '.fifo'
    result = cli.create_queue(
      {
        queue_name: queue_name,
        attributes: {
          DelaySeconds: '0',
          FifoQueue: true.to_s,
          ContentBasedDeduplication: false.to_s
        },
        tags: {
          Environment: env_name,
          ReviewAppNumber: review_app_number.to_s
        }
      }
    )
    raise result.error unless result.successful?
  end

  task fifo_job: :environment do
    require 'aws/rails/sqs_active_job/poller'
    include JobHelper
    ARGV.clear
    ARGV << '--queue'
    ARGV << 'fifo'
    Aws::Rails::SqsActiveJob::Poller.new.run
  end
end
