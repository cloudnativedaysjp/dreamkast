class DeleteMediaPackageJob < ApplicationJob
  include LogoutHelper

  queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    logger.info('Perform DeleteMediaPackageJob')
    channel = args[0]
    channel.media_package_origin_endpoints.each(&:destroy)
    channel.destroy
  rescue => e
    logger.error(e.message)
  end
end
