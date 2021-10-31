class Admin::LiveStreamMediaLiveController < ApplicationController
  include SecuredAdmin

  def bulk_create
    @conference.tracks.each do |track|
    # [Track.find(20), Track.find(21)].each do |track|
      unless track.live_stream_media_live.present?
        CreateMediaLiveJob.perform_later(@conference, track)
      end
    end

    respond_to do |format|
      format.html { redirect_to admin_live_stream_ivs_path, notice: 'IVS successfully created.' }
    end
  end

  def bulk_delete
    params[:media_live].each_key do |id, _|
      media_live = LiveStreamMediaLive.find(id)
      DeleteMediaLiveJob.perform_later(media_live)
    end

    respond_to do |format|
      format.html { redirect_to admin_live_stream_ivs_path, notice: '' }
    end
  end
end
