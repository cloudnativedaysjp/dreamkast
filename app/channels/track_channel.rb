class TrackChannel < ApplicationCable::Channel
  def subscribed
    stream_from "track_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
