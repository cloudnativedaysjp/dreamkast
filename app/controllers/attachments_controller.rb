class AttachmentsController < ApplicationController
  include Secured
  before_action :set_profile

  def show
    pdf = SponsorAttachmentPdf.find(params[:id])
    redirect_to(pdf.file_url)
  end
end
