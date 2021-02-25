class OnAirChannel < ApplicationCable::Channel
  def subscribed
    stream_from "on_air_#{params["eventAbbr"]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def update
  end
end
