class DeleteMediaPackageJob < ApplicationJob
  include LogoutHelper

  queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    logger.info('Perform DeleteMediaPackageJob')
    media_package = args[0]
    media_package.destroy
  rescue => e
    logger.error(e.message)
  end
end
