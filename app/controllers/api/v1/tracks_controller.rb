class Api::V1::TracksController < ApplicationController
  def index
    @conference = Conference.find_by(abbr: params[:eventAbbr])
    @tracks = Track.where(conference_id: @conference.id)
    render("api/v1/tracks/index.json.jbuilder")
  end

  def show
    @track = Track.find(params[:id])
    render("api/v1/tracks/show.json.jbuilder")
  end

  def viewer_count
    @count = ViewerCount.where(track_id: params[:id]).order(created_at: :desc).limit(1)[0]
    if @count
      render("api/v1/tracks/viewer_count.json.jbuilder")
    else
      render_404
    end
  end
end
