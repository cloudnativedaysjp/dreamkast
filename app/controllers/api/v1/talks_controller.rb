class Api::V1::TalksController < ApplicationController
  def index
    conference = Conference.find_by(abbr: params[:eventAbbr])
    query = {conference_id: conference.id}
    query[:track_id] = params[:trackId] if params[:trackId]
    @talks = Talk.where(query)
    render 'api/v1/talks/index.json.jbuilder'
  end

  def show
    @talk = Talk.find(params[:id])
    render 'api/v1/talks/show.json.jbuilder'
  end
end
