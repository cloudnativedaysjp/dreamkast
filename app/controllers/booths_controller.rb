class BoothsController < ApplicationController
  include Secured
  before_action :set_profile

  def index
    @conference = Conference.find_by(abbr: params[:event])
    @booths = @conference.booths
  end

  def show
    @conference = Conference.find_by(abbr: params[:event])
    @booth = @conference.booths.find(params[:id])
  end

  private

  def set_profile
    @profile = Profile.find_by(email: @current_user[:info][:email])
  end
end
