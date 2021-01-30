class Api::V1::TracksController < ApplicationController
  def index
    conference = Conference.find_by(abbr: params[:eventId])
    @tracks = Track.where(conference_id: conference.id)
    render 'api/v1/tracks/index.json.jbuilder'
  end
end
