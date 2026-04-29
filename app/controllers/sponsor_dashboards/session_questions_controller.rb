class SponsorDashboards::SessionQuestionsController < ApplicationController
  include SecuredSponsor
  before_action :set_sponsor_contact
  before_action :set_sponsor
  before_action :authorize_sponsor_contact!

  def index
    @talks = @sponsor.talks.includes(session_questions: :session_question_answers).order(:start_time)
  end

  private

  def set_sponsor_contact
    return unless current_user && current_user_model

    @sponsor_contact = SponsorContact.find_by(conference_id: current_conference.id, user_id: current_user_model.id)
  end

  def set_sponsor
    @sponsor = Sponsor.find(params[:sponsor_id])
  end

  def authorize_sponsor_contact!
    return if @sponsor_contact && @sponsor_contact.sponsor_id == @sponsor.id

    render_404
  end
end
