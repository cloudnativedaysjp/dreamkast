class Admin::TracksController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @tracks = @conference.tracks
  end

  def update_tracks
    track = Track.find(params[:track][:id])
    track.video_id = params[:track][:video_id]

    respond_to do |format|
      if track.save && TalksHelper.update_talks(@conference, params[:video])
        format.js
      end
    end
  end
end
