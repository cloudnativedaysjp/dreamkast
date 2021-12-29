class Api::V1::BoothsController < ApplicationController
  def show
    @booth = Booth.find(params[:id])
    @conference = @booth.sponsor.conference
    render('api/v1/booths/show.json.jbuilder')
  end
end
