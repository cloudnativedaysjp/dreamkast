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

  private

  def profile_name(profile)
    if profile.public_profile&.nickname.present?
      profile.public_profile.nickname
    elsif profile.last_name.present? || profile.first_name.present?
      "#{profile.last_name} #{profile.first_name}".strip
    else
      '匿名ユーザー'
    end
  end

  helper_method :profile_name
end
