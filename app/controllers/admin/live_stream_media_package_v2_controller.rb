class Admin::LiveStreamMediaPackageV2Controller < ApplicationController
  include SecuredAdmin

  def bulk_create
    @conference.tracks.each do |track|
      CreateMediaPackageV2Job.perform_later(@conference, track) # unless track.media_package_v2_channel.present?
    end

    respond_to do |format|
      format.html { redirect_to(admin_live_stream_ivs_path, notice: 'MediaPackage successfully created.') }
    end
  end

  def bulk_delete
    params[:media_package].each_key do |id, _|
      DeleteMediaPackageJob.perform_later(MediaPackageChannel.find(id))
    end

    respond_to do |format|
      format.html { redirect_to(admin_live_stream_ivs_path, notice: '') }
    end
  end
end
