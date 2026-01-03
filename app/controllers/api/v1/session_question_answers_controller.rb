class Api::V1::SessionQuestionAnswersController < ApplicationController
  include SecuredPublicApi
  before_action :set_talk
  before_action :set_question
  before_action :set_speaker
  before_action :verify_speaker

  skip_before_action :verify_authenticity_token

  def index
    answers = @question.session_question_answers.order_by_time
    render json: {
      answers: answers.map { |a| answer_json(a) }
    }
  end

  def create
    answer = @question.session_question_answers.build(
      conference_id: @talk.conference_id,
      speaker_id: @speaker.id,
      body: answer_params
    )

    if answer.save
      # ブロードキャスト
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

  def set_speaker
    return unless current_user_model
    @speaker = Speaker.find_by(conference_id: @talk.conference_id, user_id: current_user_model.id)
  end

  def verify_speaker
    unless @speaker && @talk.speakers.include?(@speaker)
      render json: { error: 'Only speakers can answer questions' }, status: :forbidden
      nil
    end
  end

  def answer_json(answer)
    {
      id: answer.id,
      body: answer.body,
      speaker: {
        id: answer.speaker.id,
        name: answer.speaker.name
      },
      created_at: answer.created_at.iso8601
    }
  end

  def broadcast_answer_created(answer)
    begin
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
      # ブロードキャストエラーは無視して処理を続行
    end
  end
end
