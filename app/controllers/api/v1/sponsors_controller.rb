class Api::V1::SponsorsController < ApplicationController
  def index
    @conference = Conference.find_by(abbr: params[:eventAbbr])
    @sponsors = Sponsor.where(conference_id: @conference.id)
    render(:index, formats: :json, type: :jbuilder)
  end
end
