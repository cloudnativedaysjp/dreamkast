class TracksController < ApplicationController

  def index
    @current = Video.where(on_air: true)
    @tracks = Track.all
  end

  def ping
    ActionCable.server.broadcast(
      "track_channel", Video.on_air
    )
  end
end
