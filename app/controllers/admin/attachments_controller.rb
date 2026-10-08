class Admin::AttachmentsController < ApplicationController
  include SecuredAdmin
  before_action :set_profile

  def show
    pdf = SponsorAttachmentPdf.joins(:sponsor).where(sponsors: { conference_id: current_conference.id }).find(params[:id])
    redirect_to(pdf.file_url)
  end
end
