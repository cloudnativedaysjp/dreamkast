module JobHelper
  include EnvHelper

  DEFAULT_FIFO_QUEUE_URL = 'http://localhost:4566/000000000000/fifo.fifo'.freeze

  def sqs_queue_url
    if ENV['SQS_FIFO_QUEUE_URL'].present?
      Rails.logger.info("[JobHelper#sqs_queue_url] using ENV SQS_FIFO_QUEUE_URL=#{ENV['SQS_FIFO_QUEUE_URL']}")
      return ENV['SQS_FIFO_QUEUE_URL']
    end

    namespace = ENV['DREAMKAST_NAMESPACE'].to_s
    if namespace.blank?
      Rails.logger.warn("[JobHelper#sqs_queue_url] DREAMKAST_NAMESPACE is blank, fallback to #{DEFAULT_FIFO_QUEUE_URL}")
      return DEFAULT_FIFO_QUEUE_URL
    end

    cli = Aws::SQS::Client.new(region: 'ap-northeast-1')
    queue_name = "review_app_#{review_app_number}.fifo"
    Rails.logger.info("[JobHelper#sqs_queue_url] resolving queue_name=#{queue_name} namespace=#{namespace}")
    result = cli.get_queue_url({ queue_name: })
    raise(result.error) unless result.successful?
    Rails.logger.info("[JobHelper#sqs_queue_url] resolved queue_url=#{result.queue_url}")
    result.queue_url
  rescue StandardError => e
    Rails.logger.warn("Failed to resolve SQS queue URL (#{e.class}: #{e.message}), fallback to #{DEFAULT_FIFO_QUEUE_URL}")
    DEFAULT_FIFO_QUEUE_URL
  end
end
