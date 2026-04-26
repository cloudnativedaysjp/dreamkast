class Api::V1::SponsorsController < ApplicationController
  def index
    @sponsors = Sponsor.where(conference_id: current_conference.id)
    render(:index, formats: :json, type: :jbuilder)
  end
end
