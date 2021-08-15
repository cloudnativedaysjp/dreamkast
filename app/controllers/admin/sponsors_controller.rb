class Admin::SponsorsController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?, :set_conference

  def index
    @sponsor_types = @conference.sponsor_types.order(order: "ASC")
    @sponsors = @conference.sponsors
  end

  def show
    @sponsor = Sponsor.find(params[:id])
  end

  def edit
    @sponsor = Sponsor.find(params[:id])
    @sponsor_form = SponsorForm.new(sponsor: @sponsor)
    @sponsor_form.load
  end

  def update
    @sponsor = Sponsor.find(params[:id])
    @sponsor_form = SponsorForm.new(sponsor_params, sponsor: @sponsor)

    respond_to do |format|
      if @sponsor_form.save
        format.html { redirect_to admin_sponsor_url(event: params[:event], id:params[:id]), notice: "Sponsor was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  private

  def is_admin?
    raise Forbidden unless admin?
  end

  def sponsor_params
    params.require(:sponsor).permit(:description,
                                    :speaker_emails,
                                    :booth_published,
                                    :attachment_text,
                                    :attachment_vimeo,
                                    :attachment_zoom,
                                    :attachment_miro,
                                    sponsor_attachment_key_images_attributes: [:id, :title, :file, :_destroy],
                                    sponsor_attachment_pdfs_attributes: [:id, :title, :file, :_destroy])
  end
end
