class DeleteStreamingAwsResourcesJob < ApplicationJob
  include EnvHelper
  include LogoutHelper

  # queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    # Rails.logger.level = Logger::DEBUG
    logger.info('Perform DeleteStreamingAwsResourcesJob')
    @streaming = args[0]

    @streaming.update!(error_cause: '', status: 'deleting')

    delete_media_live_resources
    delete_media_package_resources
    delete_media_package_v2_resources

    @streaming.update!(status: 'deleted')
    @streaming.update!(error_cause: '')
  rescue => e
    @streaming.update!(status: 'delete_error', error_cause: e.message)
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

  def delete_media_package_resources
    logger.info('Deleting MediaPackage resources...')

    @streaming.media_package_origin_endpoint&.destroy!
    @streaming.media_package_parameter&.destroy!
    @streaming.media_package_channel&.media_package_harvest_jobs&.each(&:destroy)
    @streaming.media_package_channel&.destroy!

    logger.info('Deleted MediaPackage resources...')
  end

  def delete_media_live_resources
    logger.info('Deleting MediaLive resources...')

    if @streaming.media_live_channel
      @streaming.media_live_channel.delete_aws_resource
      @streaming.media_live_channel.destroy!
    end

    if @streaming.media_live_input
      @streaming.media_live_input.delete_aws_resource
      @streaming.media_live_input.destroy!
    end

    if @streaming.media_live_input_security_group
      @streaming.media_live_input_security_group.delete_aws_resource
      @streaming.media_live_input_security_group.destroy!
    end

    logger.info('Deleted MediaLive resources...')
  end
end
