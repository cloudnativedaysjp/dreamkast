class BoothsController < ApplicationController
  include Secured
  before_action :set_profile

  def index
    conference = Conference.first
    @sponsors = SponsorType.find_by(conference_id: conference.id, name: "Booth").sponsors
  end

  private

  def set_profile
    @profile = Profile.find_by(email: @current_user[:info][:email])
  end
end
