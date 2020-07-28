class TracksController < ApplicationController

  def index
    @current = Video.where(on_air: true)
    @tracks = Track.all
  end
  
  def realtime
    @messages = Message.all
  end

end
