class Admin::TracksController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?, :set_conference

  def index
    @tracks = @conference.tracks
  end

  def update_tracks
    respond_to do |format|
      TalksHelper.update_talks(@conference, params[:video])
      format.js
    end
  end
  private

  def is_admin?
    raise Forbidden unless admin?
  end
end
