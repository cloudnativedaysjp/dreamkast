class DeleteStreamingAwsResourcesJob < ApplicationJob
  include EnvHelper
  include MediaPackageV2Helper
  include LogoutHelper

  # queue_as :default
  self.queue_adapter = :async

  attr_reader :conference
  attr_reader :track

  def perform(*args)
    # Rails.logger.level = Logger::DEBUG
    logger.info('Perform DeleteStreamingAwsResourcesJob')
    @streaming = args[0]
    @conference = @streaming.conference
    @track = @streaming.track

    delete_ivs_resources(track)
    delete_media_live_resources(track)
    delete_media_package_v2_resources(track)
    delete_media_package_resources(track)

    @streaming.update!(status: 'deleted')
  rescue => e
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  end

  def delete_ivs_resources(track)
    logger.info('Deleting IVS resources...')

    if track.ivs_channel
      track.ivs_channel.delete_aws_resource
      track.ivs_channel.destroy!
    end

    logger.info('Deleted IVS resources...')
  end

  def delete_media_package_v2_resources(track)
    logger.info('Deleting MediaPackageV2 resources...')

    if track.media_package_v2_origin_endpoint
      track.media_package_v2_origin_endpoint.delete_aws_resource
      track.media_package_v2_origin_endpoint.destroy!
    end

    if track.media_package_v2_channel
      track.media_package_v2_channel.delete_aws_resource
      track.media_package_v2_channel.destroy!
    end

    if track.media_package_v2_channel_group
      track.media_package_v2_channel_group.delete_aws_resource
      track.media_package_v2_channel_group.destroy!
    end

    logger.info('Deleted MediaPackageV2 resources...')
  end

  def delete_media_package_resources(track)
    logger.info('Deleting MediaPackage resources...')

    if track.media_package_channel&.media_package_origin_endpoints&.any?
      track.media_package_channel.media_package_origin_endpoints.each do |endpoint|
        endpoint.delete_aws_resource
        endpoint.destroy!
      end
    end

    if track.media_package_channel&.media_package_parameter
      track.media_package_channel.media_package_parameter.delete_aws_resource
      track.media_package_channel.media_package_parameter.destroy!
    end

    if track.media_package_channel
      track.media_package_channel.media_package_harvest_jobs&.each(&:destroy)
      track.media_package_channel.delete_aws_resource
      track.media_package_channel.destroy!
    end

    logger.info('Deleted MediaPackage resources...')
  end

  def delete_media_live_resources(track)
    logger.info('Deleting MediaLive resources...')

    if track.media_live_channel
      track.media_live_channel.delete_aws_resource
      track.media_live_channel.destroy!
    end

    if track.media_live_input
      track.media_live_input.delete_aws_resource
      track.media_live_input.destroy!
    end

    if track.media_live_input_security_group
      track.media_live_input_security_group.delete_aws_resource
      track.media_live_input_security_group.destroy!
    end

    logger.info('Deleted MediaLive resources...')
  end
end
