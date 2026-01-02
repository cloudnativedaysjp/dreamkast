class SpeakerDashboardsController < ApplicationController
  include SecuredSpeaker
  before_action :set_speaker
  before_action :set_conference

  def show
    @talks = @speaker ? @speaker.talks.not_sponsor : []
    @speaker_announcements = @conference.speaker_announcements.find_by_speaker(@speaker.id) unless @speaker.nil?
    
    # 未回答の質問を取得
    if @speaker && @conference
      # スピーカーが登壇しているセッションのIDを取得
      talk_ids = @speaker.talks.pluck(:id)
      
      if talk_ids.any?
        # 未回答の質問を取得（回答がない質問）
        @unanswered_questions = @conference.session_questions
          .where(talk_id: talk_ids)
          .left_joins(:session_question_answers)
          .where(session_question_answers: { id: nil })
          .includes(:talk, :profile)
          .distinct
          .order_by_time
          .limit(10) # 最新10件
      else
        @unanswered_questions = []
      end
      
      # 各セッションの質問も取得（talk_list用）
      @talks.each do |talk|
        talk.session_questions.load if talk.respond_to?(:session_questions)
      end
    else
      @unanswered_questions = []
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

    # リダイレクト先を判定（refererから判断、デフォルトはトップ）
    referer = request.referer
    if referer&.include?('questions')
      redirect_to speaker_dashboard_questions_path(event: @conference.abbr)
    elsif referer&.include?('talks')
      redirect_to speaker_dashboard_talks_path(event: @conference.abbr)
    else
      redirect_to speaker_dashboard_path(event: @conference.abbr)
    end
  end

  def talks
    @talks = @speaker ? @speaker.talks.not_sponsor : []
    @speaker_announcements = @conference.speaker_announcements.find_by_speaker(@speaker.id) unless @speaker.nil?
  end

  def questions
    @talks = @speaker ? @speaker.talks.not_sponsor : []
    
    # すべてのセッションの質問を取得（N+1対策）
    if @speaker && @conference
      # スピーカーが登壇しているセッションのIDを取得
      talk_ids = @speaker.talks.pluck(:id)
      
      if talk_ids.any?
        # セッションでフィルタ
        filtered_talk_ids = params[:talk_id].present? ? [params[:talk_id].to_i] : talk_ids
        
        @all_questions = @conference.session_questions
          .where(talk_id: filtered_talk_ids)
          .includes(:talk, :profile, :session_question_answers, :session_question_votes)
          .order_by_time
        
        # 未回答でフィルタ
        if params[:unanswered] == 'true'
          @all_questions = @all_questions
            .left_joins(:session_question_answers)
            .where(session_question_answers: { id: nil })
            .distinct
        end
        
        @all_questions = @all_questions.limit(100) # 最新100件
      else
        @all_questions = []
      end
    else
      @all_questions = []
    end
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
