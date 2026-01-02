class SpeakerDashboardsController < ApplicationController
  include SecuredSpeaker
  include Admin::TalkTableHelper
  before_action :set_speaker
  before_action :set_conference

  def show
    @talks = @speaker ? @speaker.talks.not_sponsor : []
    @speaker_announcements = @conference.speaker_announcements.find_by_speaker(@speaker.id) unless @speaker.nil?

    # 未回答の質問を取得
    if @speaker && @conference
      # スピーカーが登壇しているセッションのIDを取得
      talk_ids = @speaker.talks.pluck(:id)

      @unanswered_questions = if talk_ids.any?
                                # 未回答の質問を取得（回答がない質問）
                                # 非表示の質問は除外
                                @conference.session_questions
                                           .visible
                                           .where(talk_id: talk_ids)
                                           .left_joins(:session_question_answers)
                                           .where(session_question_answers: { id: nil })
                                           .includes(:talk, :profile)
                                           .distinct
                                           .order_by_time
                                           .limit(10) # 最新10件
                              else
                                []
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
    @talk = @speaker.talks.find_by(id: params[:talk_id])
    unless @talk
      flash[:alert] = 'このセッションの登壇者ではありません'
      redirect_to speaker_dashboard_path(event: @conference.abbr)
      return
    end

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
      flash.now[:notice] = '回答を投稿しました'
      @question.reload # 回答を再読み込み
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to speaker_dashboard_questions_path(event: @conference.abbr) }
      end
    else
      flash.now[:alert] = answer.errors.full_messages.join(', ')
      respond_to do |format|
        format.turbo_stream { render :create_answer_error, status: :unprocessable_entity }
        format.html { redirect_to speaker_dashboard_questions_path(event: @conference.abbr) }
      end
    end
  end

  def destroy_answer
    @talk = @speaker.talks.find_by(id: params[:talk_id])
    unless @talk
      flash[:alert] = 'このセッションの登壇者ではありません'
      redirect_to speaker_dashboard_path(event: @conference.abbr)
      return
    end

    @question = @talk.session_questions.find(params[:session_question_id])
    @answer = @question.session_question_answers.find(params[:id])

    unless @talk.speakers.include?(@speaker)
      flash[:alert] = 'このセッションの登壇者ではありません'
      redirect_to speaker_dashboard_path(event: @conference.abbr)
      return
    end

    unless @answer.speaker_id == @speaker.id
      flash[:alert] = 'この回答を削除する権限がありません'
      redirect_to speaker_dashboard_questions_path(event: @conference.abbr)
      return
    end

    if @answer.destroy
      # ActionCableでブロードキャスト
      broadcast_answer_deleted(@answer, @question)
      flash.now[:notice] = '回答を削除しました'
      @question.reload # 回答を再読み込み
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to speaker_dashboard_questions_path(event: @conference.abbr) }
      end
    else
      flash.now[:alert] = '回答の削除に失敗しました'
      respond_to do |format|
        format.turbo_stream { render :destroy_answer_error, status: :unprocessable_entity }
        format.html { redirect_to speaker_dashboard_questions_path(event: @conference.abbr) }
      end
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
                                    .visible
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

  helper_method :sponsor?, :turbo_stream_flash

  def sponsor?
    @conference.sponsor_contacts.where(user_id: current_user_model.id).present?
  end

  def logged_in_using_omniauth?
    current_user
  end

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'application/flash')
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

  def broadcast_answer_deleted(answer, question)
    begin
      talk = question.talk

      ActionCable.server.broadcast(
        "qa_talk_#{talk.id}",
        {
          type: 'answer_deleted',
          question_id: question.id,
          answer_id: answer.id
        }
      )
    rescue StandardError => e
      Rails.logger.error "Error broadcasting answer_deleted: #{e.class} - #{e.message}"
      # ブロードキャストエラーは無視して処理を続行
    end
  end
end
