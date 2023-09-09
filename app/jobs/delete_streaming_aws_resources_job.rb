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
    delete_media_package_resources

    @streaming.update!(status: 'deleted')
  rescue => e
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  end

  def delete_media_package_v2_resources
    logger.info('Deleting MediaPackageV2 resources...')

    if @streaming.media_package_v2_origin_endpoint
      @streaming.media_package_v2_origin_endpoint.delete_aws_resource
      @streaming.media_package_v2_origin_endpoint.destroy!
    end

    if @streaming.media_package_v2_channel
      @streaming.media_package_v2_channel.delete_aws_resource
      @streaming.media_package_v2_channel.destroy!
    end

    if @streaming.media_package_v2_channel_group
      @streaming.media_package_v2_channel_group.delete_aws_resource
      @streaming.media_package_v2_channel_group.destroy!
    end

    logger.info('Deleted MediaPackageV2 resources...')
  end

  def delete_media_package_resources
    logger.info('Deleting MediaPackage resources...')

    if @streaming.media_package_origin_endpoint
      @streaming.media_package_origin_endpoint.delete_aws_resource
      @streaming.media_package_origin_endpoint.destroy!
    end

    if @streaming.media_package_parameter
      @streaming.media_package_parameter.delete_aws_resource
      @streaming.media_package_parameter.destroy!
    end

    if @streaming.media_package_channel
      @streaming.media_package_channel.media_package_harvest_jobs&.each(&:destroy)
      @streaming.media_package_channel.delete_aws_resource
      @streaming.media_package_channel.destroy!
    end

    logger.info('Deleted MediaPackage resources...')
  end
end
