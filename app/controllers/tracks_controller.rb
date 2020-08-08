class TracksController < ApplicationController

  def index
    @current = Video.on_air
    @tracks = Track.all
  end

  def ping
    ActionCable.server.broadcast(
      "track_channel", Video.on_air
    )
    
  end
end
