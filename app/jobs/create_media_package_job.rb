class CreateMediaPackageJob < ApplicationJob
  include LogoutHelper

  # queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    logger.info('Perform CreateMediaPackageJob')
    conference, track = args

    channel = MediaPackageChannel.new(conference:, track:)
    logger.error("Failed to create MediaPackageChannel: #{channel.errors}") unless channel.save
    channel.create_aws_resource

    endpoint = MediaPackageOriginEndpoint.new(conference:, media_package_channel: channel)
    logger.error("Failed to create MediaPackageChannel: #{endpoint.errors}") unless endpoint.save
    endpoint.create_aws_resource
  rescue => e
    logger.error(e.message)
  end
end
