class Admin::AttachmentsController < ApplicationController
  include SecuredAdmin
  before_action :set_profile

  def show
    pdf = SponsorAttachmentPdf.find(params[:id])
    redirect_to(pdf.file_url)
  end
end
