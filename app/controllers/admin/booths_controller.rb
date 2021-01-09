class Admin::BoothsController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?, :set_conference

  def index
    @booths = @conference.booths
  end

  def show
    @sponsor = Sponsor.find(params[:id])
  end

  private

  def is_admin?
    raise Forbidden unless admin?
  end
end
