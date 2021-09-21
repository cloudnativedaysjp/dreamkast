class Admin::BoothsController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @booths = @conference.booths
  end

  def show
    @sponsor = Sponsor.find(params[:id])
  end
end
