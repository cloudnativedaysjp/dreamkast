class CreateStreamingAwsResourcesJob < ApplicationJob
  include EnvHelper
  include LogoutHelper

  # queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    # Rails.logger.level = Logger::DEBUG
    logger.info('Perform CreateMediaPackageV2Job')
    @streaming = args[0]

    @streaming.update!(status: 'created')
  rescue => e
    @streaming.update!(status: 'error')
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  end
end
