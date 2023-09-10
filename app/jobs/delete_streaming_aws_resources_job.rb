class DeleteStreamingAwsResourcesJob < ApplicationJob
  include EnvHelper
  include LogoutHelper

  # queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    # Rails.logger.level = Logger::DEBUG
    logger.info('Perform DeleteStreamingAwsResourcesJob')
    @streaming = args[0]

    delete_media_package_v2_resources

    @streaming.update!(status: 'deleted')
  rescue => e
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  end

  def delete_media_package_v2_resources
    logger.info('Deleting MediaPackageV2 resources...')

    @streaming.media_package_v2_origin_endpoint&.destroy!
    @streaming.media_package_v2_channel&.destroy!
    @streaming.media_package_v2_channel_group&.destroy!

    logger.info('Deleted MediaPackageV2 resources...')
  end
end
