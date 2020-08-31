class TracksController < ApplicationController
  include Secured
  before_action :set_profile

  def index
    @conference = Conference.includes(:talks).find_by(abbr: event_name)
    @current = Video.on_air
    @tracks = Track.all
    @booths = Booth.where(conference_id: @conference.id)
  end

  def blank
    render :layout => false
  end

  private
  def set_profile
    if @current_user
      @profile = Profile.find_by(email: @current_user[:info][:email])
    end
  end
end
