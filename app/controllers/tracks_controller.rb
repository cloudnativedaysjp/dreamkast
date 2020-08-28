class TracksController < ApplicationController

  def index
    @conference = Conference.includes(:talks).find_by(abbr: event_name)
    @current = Video.on_air
    @tracks = Track.all
    @booths = Booth.where(conference_id: @conference.id)
  end

  def blank
    render :layout => false
  end
end
