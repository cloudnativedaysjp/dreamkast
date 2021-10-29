require "aws-sdk-medialive"

class WaitChannelStoppedJob < ApplicationJob
  include LogoutHelper

  queue_as :default
  self.queue_adapter = if ENV['RAILS_ENV'] == 'production'
                         :amazon_sqs
                       else
                         :async
                       end

  def perform(*args)
    talk = args[0]
    logger.info "Perform WaitChannelStoppedJob: talk_id=#{talk.id}"

    talk.track.live_stream_media_live.wait_stopped
    talk.video.update!(site: 's3', video_id: talk.track.live_stream_media_live.playback_url)
    payload = {
      event: 'channel_stopped',
      channel_id: talk.track.live_stream_media_live.channel_id,
      track_name: talk.track.name,
      talk_id: talk.id
    }
    ActionCable.server.broadcast("recording_channel", payload)

    logger.info "Finished WaitChannelStoppedJob: talk_id=#{talk.id}"
  rescue => e
    logger.error e.message
  end
end
