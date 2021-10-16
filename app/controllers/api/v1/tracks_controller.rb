class Api::V1::TracksController < ApplicationController
  def index
    @conference = Conference.find_by(abbr: params[:eventAbbr])
    @tracks = Track.where(conference_id: @conference.id)
    render 'api/v1/tracks/index.json.jbuilder'
  end

  def show
    @track = Track.find(params[:id])
    render 'api/v1/tracks/show.json.jbuilder'
  end
end
