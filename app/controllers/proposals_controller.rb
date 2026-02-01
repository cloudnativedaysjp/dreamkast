class ProposalsController < ApplicationController
  include Secured
  before_action :set_profile, :set_speaker

  helper_method :proposal_status

  def logged_in_using_omniauth?
    # nop
  end

  def show
    @conference = Conference.find_by(abbr: event_name)
    @proposal = Proposal.find_by(id: params[:id], conference_id: @conference.id)
    @talk = @proposal.talk
  end

  def index
    @conference = Conference.find_by(abbr: event_name)
    @proposals = Proposal
                 .includes(talk: [:speakers, :talk_category, :talks_speakers, :talk_types])
                 .joins(:talk)
                 .merge(Talk.regular_sessions)
                 .where(conference_id: @conference.id)
  end

  def proposal_status
    "($#{@proposal.status_message})"
  end

  def use_secured_before_action?
    false
  end

  private

  def should_redirect?
    false
  end
end
