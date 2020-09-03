class Admin::TracksController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?

  def index
    @conference = Conference.find_by(abbr: "cndt2020")
    @tracks = @conference.tracks
  end

  private

  def is_admin?
    raise Forbidden unless admin?
  end
end
