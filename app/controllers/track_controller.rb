class TrackController < ApplicationController
  include Secured
  include Logging
  before_action :set_profile

  def show
    @tracks = Track.all
    @event = params[:event]

    @new_user = new_user?.to_s
    @movie_url = @tracks.find_by(number: params[:id].to_i).movie_url
  end

  private

  def set_profile
    @profile = Profile.find_by(email: @current_user[:info][:email])
  end
end
