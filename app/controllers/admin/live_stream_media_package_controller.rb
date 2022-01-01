class Admin::LiveStreamMediaPackageController < ApplicationController
  include SecuredAdmin

  def bulk_create
    @conference.tracks.each do |track|
      unless track.media_package_channel.present?
        CreateMediaPackageJob.perform_later(@conference, track)
      end
    end

    respond_to do |format|
      format.html { redirect_to(admin_live_stream_ivs_path, notice: 'MediaPackage successfully created.') }
    end
  end

  def bulk_delete
    params[:media_package].each_key do |id, _|
      media_live = MediaPackageChannel.find(id)
      DeleteMediaPackageJob.perform_later(media_live)
    end

    respond_to do |format|
      format.html { redirect_to(admin_live_stream_ivs_path, notice: '') }
    end
  end
end
