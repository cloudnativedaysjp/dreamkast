class Api::V1::BoothsController < ApplicationController
  def show
    @booth = Booth.find(params[:id])
    @conference = @booth.sponsor.conference
    render(:show, formats: :json, type: :jbuilder)
  end
end
