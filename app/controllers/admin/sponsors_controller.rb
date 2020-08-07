class Admin::SponsorsController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?

  def index
    @sponsors = Sponsor.all
  end

  def show
    @sponsor = Sponsor.find(params[:id])
  end

  def edit
    @sponsor = Sponsor.find(params[:id])
    @sponsor_form = SponsorForm.new(sponsor: @sponsor)
  end

  def update
    @sponsor = Sponsor.find(params[:id])
    @sponsor_form = SponsorForm.new(sponsor_params, sponsor: @sponsor)

    respond_to do |format|
      if @sponsor_form.save
        format.html { redirect_to "/admin/sponsors/#{params[:id]}", notice: "Sponsor was successfully updated." }
        format.json { render :show, status: :ok, location: @sponsor }
      else
        format.html { render :edit }
        format.json { render json: @sponsor.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def is_admin?
    raise Forbidden unless admin?
  end

  def sponsor_params
    params.require(:sponsor).permit(:description,
                                    :attachment_key_image_1, :attachment_key_image_1_title,
                                    :attachment_key_image_2, :attachment_key_image_2_title,
                                    :attachment_text,
                                    :attachment_vimeo,
                                    :attachment_pdf_1, :attachment_pdf_1_title,
                                    :attachment_pdf_2, :attachment_pdf_2_title,
                                    :attachment_pdf_3, :attachment_pdf_3_title)
  end
end
