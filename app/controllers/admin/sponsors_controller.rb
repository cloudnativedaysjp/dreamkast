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
    @sponsor_form = SponsorForm.new(params: {sponsor_id: @sponsor.id})
  end

  def update
    @sponsor = Sponsor.find(params[:id])

    respond_to do |format|
      if @sponsor.update(sponsor_params)
        format.html { redirect_to "/admin/sponsors/#{params[:id]}", notice: "Sponsor #{@sponsor.name} (id: #{@sponsor.id})was successfully updated." }
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
    params.require(:sponsor_form).permit(:description)
  end
end
