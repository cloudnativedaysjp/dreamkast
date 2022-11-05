class Api::V1::TracksController < ApplicationController
  def index
    @conference = Conference.find_by(abbr: params[:eventAbbr])
    render_400 and return if @conference.nil?
    @tracks = Track.where(conference_id: @conference.id)
    render(:index, formats: :json, type: :jbuilder)
  end

  def show
    @track = Track.find(params[:id])
    render(:show, formats: :json, type: :jbuilder)
  end
end
