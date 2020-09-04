class WaitingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "waiting_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def update
    ActionCable.server.broadcast(
      "waiting_channel", Video.on_air
    )
  end
end
