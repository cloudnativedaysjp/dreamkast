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
    @sponsor_form.load
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
                                    :attachment_text,
                                    :attachment_vimeo,
                                    sponsor_attachment_key_images_attributes: [:id, :title, :file, :_destroy],
                                    sponsor_attachment_pdfs_attributes: [:id, :title, :file, :_destroy])
  end
end
