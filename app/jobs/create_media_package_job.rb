class CreateMediaPackageJob < ApplicationJob
  include LogoutHelper

  # queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    logger.info('Perform CreateMediaPackageJob')
    conference, track = args

    channel = MediaPackageChannel.new(conference: conference, track: track)
    logger.error("Failed to create MediaPackageChannel: #{channel.errors}") unless channel.save
    channel.create_media_package_resources

    endpoint = MediaPackageOriginEndpoint.new(conference: conference, media_package_channel: channel)
    logger.error("Failed to create MediaPackageChannel: #{endpoint.errors}") unless endpoint.save
    endpoint.create_media_package_resources
  rescue => e
    logger.error(e.message)
  end
end
