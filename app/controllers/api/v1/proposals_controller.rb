class Api::V1::ProposalsController < ApplicationController
  include SecuredPublicApi

  skip_before_action :authenticate_request!, only: [:index]
  skip_before_action :verify_authenticity_token

  def index
    @conference = Conference.find_by(abbr: params[:eventAbbr])
    query = { conference_id: @conference.id }
    # Get all proposals and filter out special session types
    @proposals = Proposal
                 .includes(talk: :talk_types)
                 .where(query)
                 .select do |proposal|
                   # Include talks that have no attributes or only have regular session attributes
                   talk_types = proposal.talk.talk_types.pluck(:name)
                   talk_types.empty? || talk_types.none? { |name| %w[intermission sponsor keynote].include?(name) }
                 end
    render(:index, formats: :json, type: :jbuilder)
  end
end
