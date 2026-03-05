module JobHelper
  include EnvHelper

  DEFAULT_FIFO_QUEUE_URL = 'http://localhost:4566/000000000000/fifo.fifo'.freeze

  def sqs_queue_url
    return ENV['SQS_FIFO_QUEUE_URL'] if ENV['SQS_FIFO_QUEUE_URL'].present?

    namespace = ENV['DREAMKAST_NAMESPACE'].to_s
    return DEFAULT_FIFO_QUEUE_URL if namespace.blank?

    cli = Aws::SQS::Client.new(region: 'ap-northeast-1')
    result = cli.get_queue_url({ queue_name: "review_app_#{review_app_number}.fifo" })
    raise(result.error) unless result.successful?
    result.queue_url
  rescue StandardError => e
    warn("Failed to resolve SQS queue URL (#{e.class}: #{e.message}), fallback to #{DEFAULT_FIFO_QUEUE_URL}")
    DEFAULT_FIFO_QUEUE_URL
  end
end
