class Admin::TracksController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @date = params[:date]
    @track_name = params[:track_name]
    @track = @conference.tracks.find_by(name: @track_name)
    @talks = @conference.talks.where(conference_day_id: @conference.conference_days.find_by(date: @date).id, track_id: @track.id).order('conference_day_id ASC, start_time ASC, track_id ASC')
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

  private

  helper_method :active_date_tab?, :active_track_tab?

  def active_date_tab?(conference_day)
    conference_day.date.strftime("%Y-%m-%d") == @date
  end

  def active_track_tab?(track)
    track.name == @track_name
  end
end
