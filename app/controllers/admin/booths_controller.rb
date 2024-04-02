class Admin::BoothsController < ApplicationController
  include SecuredAdmin

  def index
    @booths = @conference.booths
  end

  def show
    @sponsor = Sponsor.find(params[:id])
  end
end
