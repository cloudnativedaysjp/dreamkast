class DeleteStreamingAwsResourcesJob < ApplicationJob
  include EnvHelper
  include LogoutHelper

  # queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    # Rails.logger.level = Logger::DEBUG
    logger.info('Perform DeleteStreamingAwsResourcesJob')
    @streaming = args[0]

    @streaming.update!(status: 'deleted')
  rescue => e
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  end
end
