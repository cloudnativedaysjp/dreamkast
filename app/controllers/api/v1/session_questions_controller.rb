class Api::V1::SessionQuestionsController < ApplicationController
  include SecuredPublicApi
  before_action :set_talk
  before_action :set_profile

  skip_before_action :verify_authenticity_token

  def index
    questions = @talk.session_questions.visible
    questions = questions.order_by_votes if params[:sort] == 'votes'
    questions = questions.order_by_time if params[:sort] == 'time'

    render json: {
      questions: questions.map { |q| question_json(q) }
    }
  end

  def create
    @params ||= JSON.parse(request.body.read, { symbolize_names: true })
    body = @params[:body]

    question = @talk.session_questions.build(
      conference_id: @talk.conference_id,
      profile_id: @profile.id,
      body:
    )

    if question.save
      # ブロードキャスト
      broadcast_question_created(question)
      render json: question_json(question), status: :created
    else
      render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def vote
    question = @talk.session_questions.visible.find(params[:id])

    begin
      vote = question.session_question_votes.find_or_initialize_by(profile_id: @profile.id)

      if vote.persisted?
        vote.destroy!
        has_voted = false
      else
        vote.save!
        has_voted = true
      end

      # ブロードキャスト
      broadcast_question_voted(question, has_voted)

      render json: {
        votes_count: question.reload.votes_count,
        has_voted:
      }
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error "Error in vote action: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private

  def set_talk
    @talk = Talk.find(params[:talk_id])
  end

  def set_profile
    # talkからconferenceを取得してprofileを設定
    @conference = @talk.conference
    @profile = Profile.find_by(user_id: current_user_model.id, conference_id: @conference.id) if current_user_model
    unless @profile
      render json: { error: 'Profile not found' }, status: :unauthorized
      nil
    end
  end

  def question_json(question)
    profile = question.profile
    # プロフィール名の取得: public_profileのnicknameのみを使用
    profile_name = profile.public_profile&.nickname.presence || '匿名ユーザー'

    {
      id: question.id,
      body: question.body,
      profile: {
        id: profile.id,
        name: profile_name
      },
      votes_count: question.votes_count,
      has_voted: question.session_question_votes.exists?(profile_id: @profile.id),
      created_at: question.created_at.iso8601,
      answers: question.session_question_answers.order_by_time.map { |a| answer_json(a) }
    }
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

  def broadcast_question_created(question)
    begin
      ActionCable.server.broadcast(
        "qa_talk_#{@talk.id}",
        {
          type: 'question_created',
          question: question_json(question)
        }
      )
    rescue StandardError => e
      Rails.logger.error "Error broadcasting question_created: #{e.class} - #{e.message}"
      # ブロードキャストエラーは無視して処理を続行
    end
  end

  def broadcast_question_voted(question, has_voted)
    begin
      ActionCable.server.broadcast(
        "qa_talk_#{@talk.id}",
        {
          type: 'question_voted',
          question_id: question.id,
          votes_count: question.reload.votes_count,
          has_voted:
        }
      )
    rescue StandardError => e
      Rails.logger.error "Error broadcasting question_voted: #{e.class} - #{e.message}"
      # ブロードキャストエラーは無視して処理を続行
    end
  end
end
