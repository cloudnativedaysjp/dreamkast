class TracksController < ApplicationController

  def index
    @current = Video.on_air
    @tracks = Track.all
  end

  def blank
    
  end
end
