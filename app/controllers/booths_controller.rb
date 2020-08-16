class BoothsController < ApplicationController
  include Secured
  before_action :set_profile

  def index
    conference = Conference.first
    @booths = conference.booths
  end

  def show
    @sponsor = Sponsor.find(params[:id])
  end

  private

  def set_profile
    @profile = Profile.find_by(email: @current_user[:info][:email])
  end
end
