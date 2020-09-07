class Admin::AttachmentsController < ApplicationController
  include Secured
  include Logging
  before_action :set_profile

  def show
    pdf = SponsorAttachmentPdf.find(params[:id])
    redirect_to pdf.file_url
  end

  private

  def set_profile
    @profile = Profile.find_by(email: @current_user[:info][:email])
  end
end
