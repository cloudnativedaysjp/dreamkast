module JobHelper
  include EnvHelper

  def sqs_queue_url
    if review_app?
      cli = Aws::SQS::Client.new(region: 'ap-northeast-1')
      result = cli.get_queue_url({ queue_name: "review_app_#{review_app_number}" + '.fifo' })
      raise(result.error) unless result.successful?
      result.queue_url
    else
      ENV['SQS_FIFO_QUEUE_URL']
    end
  end
end
