class SpeakerDashboardsController < ApplicationController
  include SecuredSpeaker
  before_action :set_speaker

  def show
    @talks = @speaker ? @speaker.talks.not_sponsor : []
    @speaker_announcements = @conference.speaker_announcements.find_by_speaker(@speaker.id) unless @speaker.nil?
    
    # 各セッションの質問を取得（N+1対策）
    if @speaker
      @talks.each do |talk|
        talk.session_questions.load if talk.respond_to?(:session_questions)
      end
    end
  end

  def create_answer
    @talk = @speaker.talks.find(params[:talk_id])
    @question = @talk.session_questions.find(params[:session_question_id])

    unless @talk.speakers.include?(@speaker)
      flash[:alert] = 'このセッションの登壇者ではありません'
      redirect_to speaker_dashboard_path(event: @conference.abbr)
      return
    end

    answer = @question.session_question_answers.build(
      conference_id: @talk.conference_id,
      speaker_id: @speaker.id,
      body: params[:body]
    )

    if answer.save
      # ActionCableでブロードキャスト
      broadcast_answer_created(answer)
      flash[:notice] = '回答を投稿しました'
    else
      flash[:alert] = answer.errors.full_messages.join(', ')
    end

    redirect_to speaker_dashboard_path(event: @conference.abbr)
  end

  private

  helper_method :sponsor?

  def sponsor?
    @conference.sponsor_contacts.where(user_id: current_user_model.id).present?
  end

  def logged_in_using_omniauth?
    current_user
  end

  def broadcast_answer_created(answer)
    begin
      question = answer.session_question
      talk = question.talk
      
      ActionCable.server.broadcast(
        "qa_talk_#{talk.id}",
        {
          type: 'answer_created',
          question_id: question.id,
          answer: {
            id: answer.id,
            body: answer.body,
            speaker: {
              id: answer.speaker.id,
              name: answer.speaker.name
            },
            created_at: answer.created_at.iso8601
          }
        }
      )
    rescue StandardError => e
      Rails.logger.error "Error broadcasting answer_created: #{e.class} - #{e.message}"
      # ブロードキャストエラーは無視して処理を続行
    end
  end
end
