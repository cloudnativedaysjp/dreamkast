class Api::V1::TracksController < ApplicationController
  def index
    render_400 and return if current_conference.nil?
    @tracks = Track.where(conference_id: current_conference.id)
    render(:index, formats: :json, type: :jbuilder)
  end

  def show
    @track = Track.find(params[:id])
    render(:show, formats: :json, type: :jbuilder)
  end
end
