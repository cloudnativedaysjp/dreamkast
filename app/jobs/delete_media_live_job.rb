class DeleteMediaLiveJob < ApplicationJob
  include LogoutHelper

  queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    logger.info("Perform DeleteMediaLiveJob")
    media_live = args[0]
    media_live.destroy
  rescue => e
    logger.error(e.message)
  end
end
