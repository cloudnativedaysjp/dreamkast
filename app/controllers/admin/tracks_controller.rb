class Admin::TracksController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?

  def index
    @conference = Conference.find_by(abbr: "cndt2020")
    @tracks = @conference.tracks
  end

  def update_tracks
    TalksHelper.update_talks(params[:video])

    redirect_to '/admin/tracks', notice: "配信設定を更新しました"
  end
  private

  def is_admin?
    raise Forbidden unless admin?
  end
end
