class Api::V1::SessionQuestionAnswersController < ApplicationController
  include SecuredPublicApi
  before_action :set_talk
  before_action :set_question
  before_action :set_answerer
  before_action :verify_answerer

  skip_before_action :verify_authenticity_token

  def index
    @talk.speakers.load # answerer_display_name の per-answer N+1 を回避するため事前ロード
    answers = @question.session_question_answers
                       .includes(:speaker, :sponsor_contact)
                       .order_by_time
    render json: {
      answers: answers.map { |a| answer_json(a) }
    }
  end

  def create
    answer = @question.session_question_answers.build(
      conference_id: @talk.conference_id,
      body: answer_params
    )
    if @answerer.is_a?(Speaker)
      answer.speaker = @answerer
    else
      answer.sponsor_contact = @answerer
    end

    if answer.save
      broadcast_answer_created(answer)
      render json: answer_json(answer), status: :created
    else
      render json: { errors: answer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def answer_params
    params.fetch(:body, '')
  end

  def set_talk
    @talk = Talk.find(params[:talk_id])
  end

  def set_question
    @question = @talk.session_questions.find(params[:session_question_id])
  end

  def set_answerer
    return unless current_user_model

    speaker = Speaker.find_by(conference_id: @talk.conference_id, user_id: current_user_model.id)
    if speaker && @talk.speakers.include?(speaker)
      @answerer = speaker
      return
    end

    if @talk.sponsor_id.present?
      sponsor_contact = SponsorContact.find_by(
        conference_id: @talk.conference_id,
        sponsor_id: @talk.sponsor_id,
        user_id: current_user_model.id
      )
      @answerer = sponsor_contact if sponsor_contact
    end
  end

  def verify_answerer
    return if @answerer

    render json: { error: 'Only speakers or sponsor contacts of this talk can answer questions' }, status: :forbidden
  end

  def answer_json(answer)
    {
      id: answer.id,
      body: answer.body,
      answerer: {
        type: answer.answerer_type,
        name: answer.answerer_display_name
      },
      created_at: answer.created_at.iso8601
    }
  end

  def broadcast_answer_created(answer)
    ActionCable.server.broadcast(
      "qa_talk_#{@talk.id}",
      {
        type: 'answer_created',
        question_id: @question.id,
        answer: answer_json(answer)
      }
    )
  rescue StandardError => e
    Rails.logger.error "Error broadcasting answer_created: #{e.class} - #{e.message}"
  end
end
