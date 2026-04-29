class SponsorDashboards::SessionQuestionAnswersController < ApplicationController
  include SecuredSponsor
  before_action :set_sponsor_contact
  before_action :set_sponsor
  before_action :authorize_sponsor_contact!
  before_action :set_question

  def create
    answer = @question.session_question_answers.build(
      conference_id: @question.conference_id,
      sponsor_contact: @sponsor_contact,
      body: params.fetch(:body, '')
    )

    if answer.save
      broadcast_answer_created(answer)
      flash[:notice] = '回答を投稿しました'
    else
      flash[:alert] = "回答の投稿に失敗しました: #{answer.errors.full_messages.join(', ')}"
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

  def set_question
    @question = SessionQuestion.find(params[:session_question_id])
    return if @sponsor.talks.exists?(id: @question.talk_id)

    render_404
  end

  def broadcast_answer_created(answer)
    ActionCable.server.broadcast(
      "qa_talk_#{answer.session_question.talk_id}",
      {
        type: 'answer_created',
        question_id: @question.id,
        answer: {
          id: answer.id,
          body: answer.body,
          answerer: { type: answer.answerer_type, name: answer.answerer_display_name },
          created_at: answer.created_at.iso8601
        }
      }
    )
  rescue StandardError => e
    Rails.logger.error "Error broadcasting answer_created: #{e.class} - #{e.message}"
  end
end
