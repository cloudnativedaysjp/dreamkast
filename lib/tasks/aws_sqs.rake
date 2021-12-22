namespace :aws_sqs do
  desc "create review_app linked sqs"
  task create_sqs: :environment do
    include EnvHelper

    exit unless review_app?

    cli = Aws::SQS::Client.new(region: "ap-northeast-1")
    queue_name = "review_app_#{review_app_number}" + ".fifo"
    result = cli.create_queue(
      {
        queue_name: queue_name,
        attributes: {
          DelaySeconds: "0",
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

  task delete_sqs: :environment do
    include(EnvHelper)

    exit unless review_app?

    cli = Aws::SQS::Client.new(region: "ap-northeast-1")
    result = cli.get_queue_url({ queue_name: "review_app_#{review_app_number}" + ".fifo" })
    response = cli.delete_queue({ queue_url: result.queue_url })
    raise(response.error) unless response.successful?
  rescue Aws::SQS::Errors::NonExistentQueue
    Rails.logger.debug("Queue not exist")
  end

  task fifo_job: :environment do
    require "aws/rails/sqs_active_job/poller"
    include EnvHelper
    def queue_url
      if review_app?
        cli = Aws::SQS::Client.new(region: "ap-northeast-1")
        result = cli.get_queue_url({ queue_name: "review_app_#{review_app_number}" + ".fifo" })
        raise(result.error) unless result.successful?
        result.queue_url
      else
        ENV["SQS_FIFO_QUEUE_URL"]
      end
    end
    ARGV.clear
    ARGV << "--queue"
    ARGV << "fifo"
    Aws::Rails::SqsActiveJob::Poller.new.run
  end
end
