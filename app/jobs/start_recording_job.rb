require "aws-sdk-medialive"


class StartRecordingJob < ApplicationJob
  include LogoutHelper

  queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    talk = args[0]
    logger.info "Perform StartRecordingJob: talk_id=#{talk.id}"
    talk.track.live_stream_media_live.start_recording
  rescue => e
    logger.error e.message
  end
end
