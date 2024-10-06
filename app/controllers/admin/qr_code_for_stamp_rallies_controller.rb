class Admin::QrCodeForStampRalliesController < ApplicationController
  include SecuredAdmin

  def show
    @stamp_rally_def = StampRallyDef.find(params[:id])
    @qr_code_for_stamp_rally = QrCodeForStampRally.new(@stamp_rally_def, @conference)
  end
end
