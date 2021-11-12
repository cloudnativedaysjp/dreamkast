class WaitingChannel < ApplicationCable::Channel
  def subscribed
    stream_from("waiting_channel")
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
