class Admin::QrCodeForStampRalliesController < ApplicationController
  include SecuredAdmin

  def show
    @stamp_rally_check_point = StampRallyCheckPoint.find(params[:id])
    @qr_code_for_stamp_rally = QrCodeForStampRally.new(@stamp_rally_check_point, @conference)
  end
end
