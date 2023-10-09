class ProposalsController < ApplicationController

  helper_method :proposal_status
  def show
    @conference = Conference.find_by(abbr: event_name)
    @proposal = Proposal.find_by(id: params[:id], conference_id: @conference.id)
    @talk = @proposal.talk
  end

  def index
    @conference = Conference.find_by(abbr: event_name)
    @proposals = @conference.proposals
  end

  def proposal_status
    case @proposal.status
    when "registered"
      "(採択待ち)"
    when "accepted"
      "(採択)"
    when "rejected"
      "(落選)"
    else
      ""
    end
  end
end
