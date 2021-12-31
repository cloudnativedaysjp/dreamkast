class CreateMediaPackageJob < ApplicationJob
  include LogoutHelper

  # queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    logger.info('Perform CreateMediaPackageJob')
    conference, track = args

    media_package = LiveStreamMediaPackage.new(conference: conference, track: track)

    logger.error("Failed to create LiveStreamMediaPackage: #{media_package.errors}") unless media_package.save

    media_package.create_media_package_resources
  rescue => e
    logger.error(e.message)
  end
end
