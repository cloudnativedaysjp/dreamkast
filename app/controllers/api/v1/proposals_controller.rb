class Api::V1::ProposalsController < ApplicationController
  include SecuredPublicApi

  skip_before_action :authenticate_request!, only: [:index]
  skip_before_action :verify_authenticity_token

  def index
    conference = Conference.find_by(abbr: params[:eventAbbr])
    query = { conference_id: conference.id }
    @proposals = Proposal.where(query)
    render(:index, formats: :json, type: :jbuilder)
  end
end
