class CreateMediaLiveJob < ApplicationJob
  include LogoutHelper

  queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    logger.info('Perform CreateMediaLiveJob')
    conference, track = args

    media_live = LiveStreamMediaLive.new(conference: conference, track: track)

    logger.error("Failed to create LiveStreamMediaLive: #{media_live.errors}") unless media_live.save

    media_live.create_media_live_resources
  rescue => e
    logger.error(e.message)
  end
end
