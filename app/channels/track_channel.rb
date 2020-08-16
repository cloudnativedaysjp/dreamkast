class TrackChannel < ApplicationCable::Channel
  def subscribed
    stream_from "track_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def update
    ActionCable.server.broadcast(
      "track_channel", Video.on_air
    )
  end
end
