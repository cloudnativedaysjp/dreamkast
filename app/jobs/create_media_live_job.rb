class CreateMediaLiveJob < ApplicationJob
  include LogoutHelper

  queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    logger.info "Perform CreateMediaLiveJob"
    conference = args[0]
    track = args[1]

    media_live = LiveStreamMediaLive.new(conference: conference, track: track)

    unless media_live.save
      logger.error "Failed to create LiveStreamMediaLive: #{media_live.errors}"
    end

    media_live.create_media_live_resources
  rescue => e
    logger.error e.message
  end
end
