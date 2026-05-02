class SponsorDashboards::SessionQuestionsController < ApplicationController
  include SecuredSponsor
  before_action :set_sponsor_contact
  before_action :set_sponsor
  before_action :authorize_sponsor_contact!

  def index
    @talks = @sponsor.talks.order(:start_time)
    talk_ids = @talks.pluck(:id)

    if talk_ids.empty?
      @all_questions = []
      return
    end

    requested_talk_id = params[:talk_id].present? ? params[:talk_id].to_i : nil
    filtered_talk_ids = if requested_talk_id && talk_ids.include?(requested_talk_id)
                          [requested_talk_id]
                        else
                          talk_ids
                        end

    @all_questions = current_conference.session_questions
                                       .where(talk_id: filtered_talk_ids)
                                       .includes(:profile, :session_question_votes,
                                                 talk: :speakers,
                                                 session_question_answers: [:speaker, :sponsor_contact])
                                       .order_by_time

    if params[:unanswered] == 'true'
      @all_questions = @all_questions
                       .left_joins(:session_question_answers)
                       .where(session_question_answers: { id: nil })
                       .distinct
    end

    @all_questions = @all_questions.limit(100)
  end

  def toggle_hidden
    question = SessionQuestion.find(params[:id])

    unless @sponsor.talks.exists?(id: question.talk_id)
      render_404
      return
    end

    if question.update(hidden: !question.hidden)
      status = question.hidden? ? '非表示' : '表示'
      flash[:notice] = "質問を#{status}にしました"
      broadcast_question_toggled(question)
    else
      flash[:alert] = '状態の変更に失敗しました'
    end

    redirect_to sponsor_dashboards_session_questions_path(event: current_conference.abbr, sponsor_id: @sponsor.id)
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

  def broadcast_question_toggled(question)
    ActionCable.server.broadcast(
      "qa_talk_#{question.talk_id}",
      {
        type: 'question_toggled',
        question_id: question.id,
        hidden: question.hidden
      }
    )
  rescue StandardError => e
    Rails.logger.error "Error broadcasting question_toggled: #{e.class} - #{e.message}"
  end
end
