class LinksController < ApplicationController
  include Secured
  before_action :set_profile

  def index
    @conference = Conference.includes(talks: [:track, :speakers, :conference_day]).find_by(abbr: event_name)
    @links = Link.where(conference_id: @conference.id)
  end

  private
  def set_profile
    if @current_user
      @profile = Profile.find_by(email: @current_user[:info][:email])
    end
  end
end
