class Admin::LiveStreamMediaPackageV2Controller < ApplicationController
  include SecuredAdmin

  def bulk_create
    CreateMediaPackageV2Job.perform_later(@conference) # unless track.media_package_v2_channel.present?

    respond_to do |format|
      format.html { redirect_to(admin_live_stream_ivs_path, notice: 'MediaPackage successfully created.') }
    end
  end

  def bulk_delete
    DeleteMediaPackageV2Job.perform_later(@conference, params[:media_package_v2].keys)

    respond_to do |format|
      format.html { redirect_to(admin_live_stream_ivs_path, notice: '') }
    end
  end
end
