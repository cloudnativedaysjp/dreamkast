class Admin::LiveStreamMediaLiveController < ApplicationController
  include SecuredAdmin

  def bulk_delete
    params[:media_live].each_key do |id, _|
      ivs = LiveStreamMediaLive.find(id)
      ivs.destroy
    end

    respond_to do |format|
      format.html { redirect_to admin_live_stream_ivs_path, notice: '' }
    end
  end

end
