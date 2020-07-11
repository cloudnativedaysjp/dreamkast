class TrackController < ApplicationController
  include Secured
  include Logging
  
  def show
    @tracks = Track.all
    @event = params[:event]

    @new_user = new_user?.to_s
    @movie_url = @tracks.find_by(number: params[:id].to_i).movie_url
  end
end
