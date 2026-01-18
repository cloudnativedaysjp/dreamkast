class Admin::SessionQuestionsController < ApplicationController
  include SecuredAdmin

  def index
    @session_questions = @conference.session_questions
                                    .includes(:talk, :profile, :session_question_answers, :session_question_votes)
                                    .order(created_at: :desc)

    # トークでフィルタリング
    if params[:talk_id].present?
      @session_questions = @session_questions.where(talk_id: params[:talk_id])
    end

    # ソート
    case params[:sort]
    when 'votes'
      @session_questions = @session_questions.order(votes_count: :desc, created_at: :desc)
    when 'time'
      @session_questions = @session_questions.order(created_at: :desc)
    end

    # トーク一覧（フィルタ用）
    @talks = @conference.talks.accepted_and_intermission.order('conference_day_id ASC, start_time ASC, track_id ASC')
  end

  def show
    @session_question = @conference.session_questions
                                   .includes(:talk, :profile, :session_question_answers, :session_question_votes)
                                   .find(params[:id])
  end

  def toggle_hidden
    @session_question = @conference.session_questions.find(params[:id])

    if @session_question.update(hidden: !@session_question.hidden)
      status = @session_question.hidden? ? '非表示' : '表示'
      flash[:notice] = "質問を#{status}にしました"
    else
      flash[:alert] = '状態の変更に失敗しました'
    end

    redirect_to admin_session_question_path(@session_question, event: params[:event])
  end
end
