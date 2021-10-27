require "aws-sdk-medialive"


class StartRecordingJob < ApplicationJob
  include LogoutHelper

  queue_as :default
  self.queue_adapter = if ENV['RAILS_ENV'] == 'production'
                         :amazon_sqs
                       else
                         :async
                       end

  def perform(*args)
    talk = args[0]
    logger.info "Perform StartRecordingJob: talk_id=#{talk.id}"

    talk.track.live_stream_media_live.start_recording

    payload = {
      event: 'channel_stopped',
      channel_id: talk.track.live_stream_media_live.channel_id,
      track_name: talk.track.name,
      talk_id: talk.id
    }
    ActionCable.server.broadcast("recording_channel", payload)
  rescue => e
    logger.error e.message
  end
end
