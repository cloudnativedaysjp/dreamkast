class ProfilesController < ApplicationController
  include Secured
  def new
    @profile = Profile.new
  end

  def show
    @profile = Profile.find_by(sub: @current_user[:extra][:raw_info][:sub])
  end

  def create
  end
end
