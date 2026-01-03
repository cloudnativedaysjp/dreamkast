class TalksController < ApplicationController
  include Secured
  before_action :set_profile, :set_speaker
  helper_method :talk_start_to_end

  def logged_in_using_omniauth?
    current_user
  end

  # - プロポーザルの採択結果を表示する場合
  #   - プロポーザルが採択されている場合：セッション情報を表示する
  #   - プロポーザルが採択されていない場合：404を返す
  # - プロポーザルの採択結果を表示しない場合：404を返す
  # - Conferenceのstatusが `migrated` の場合：websiteにリダイレクトする
  def show
    @conference = Conference.find_by(abbr: event_name)
    @talk = Talk.find_by(id: params[:id], conference_id: @conference.id)

    raise(ActiveRecord::RecordNotFound) unless @talk

    unless @conference.cfp_result_visible
      raise(ActiveRecord::RecordNotFound)
    end

    if @conference.cfp_result_visible && @talk.proposal.rejected?
      raise(ActiveRecord::RecordNotFound)
    end

    # QA一覧を取得（新しい順でソート）
    # 常に取得（質問がない場合も空配列を返す）
    # 非表示の質問は除外
    @session_questions = @talk.session_questions
                              .visible
                              .includes(:session_question_answers, :session_question_votes, profile: :public_profile)
                              .order_by_time
  end

  def create_question
    @conference = Conference.find_by(abbr: event_name)
    @talk = Talk.find_by(id: params[:id], conference_id: conference.id)

    unless @talk
      flash[:alert] = 'セッションが見つかりません'
      redirect_to talk_path(id: params[:id], event: event_name)
      return
    end

    unless @profile
      flash[:alert] = 'ログインが必要です'
      redirect_to talk_path(id: params[:id], event: event_name)
      return
    end

    question = @talk.session_questions.build(
      conference_id: @talk.conference_id,
      profile_id: @profile.id,
      body: params[:body]
    )

    if question.save
      # ActionCableでブロードキャスト
      broadcast_question_created(question)
      flash[:notice] = '質問を投稿しました'
    else
      flash[:alert] = question.errors.full_messages.join(', ')
    end

    redirect_to talk_path(id: params[:id], event: event_name)
  end

  def destroy_question
    @conference = Conference.find_by(abbr: event_name)
    @talk = Talk.find_by(id: params[:id], conference_id: @conference.id)

    unless @talk
      flash[:alert] = 'セッションが見つかりません'
      redirect_to talk_path(id: params[:id], event: event_name)
      return
    end

    unless @profile
      flash[:alert] = 'ログインが必要です'
      redirect_to talk_path(id: params[:id], event: event_name)
      return
    end

    question = @talk.session_questions.find_by(id: params[:question_id])

    unless question
      flash[:alert] = '質問が見つかりません'
      redirect_to talk_path(id: params[:id], event: event_name)
      return
    end

    # 自分の質問のみ削除可能
    unless question.profile_id == @profile.id
      flash[:alert] = '自分の質問のみ削除できます'
      redirect_to talk_path(id: params[:id], event: event_name)
      return
    end

    if question.destroy
      broadcast_question_deleted(question.id)
      flash[:notice] = '質問を削除しました'
    else
      flash[:alert] = '質問の削除に失敗しました'
    end

    redirect_to talk_path(id: params[:id], event: event_name)
  end

  def broadcast_question_created(question)
    begin
      profile = question.profile

      question_data = {
        id: question.id,
        body: question.body,
        profile: {
          id: profile.id,
          name: profile.public_name
        },
        votes_count: question.votes_count,
        has_voted: false,
        created_at: question.created_at.iso8601,
        answers: []
      }

      ActionCable.server.broadcast(
        "qa_talk_#{@talk.id}",
        {
          type: 'question_created',
          question: question_data
        }
      )
    rescue StandardError => e
      Rails.logger.error "Error broadcasting question_created: #{e.class} - #{e.message}"
      # ブロードキャストエラーは無視して処理を続行
    end
  end

  def broadcast_question_deleted(question_id)
    begin
      ActionCable.server.broadcast(
        "qa_talk_#{@talk.id}",
        {
          type: 'question_deleted',
          question_id: question_id
        }
      )
    rescue StandardError => e
      Rails.logger.error "Error broadcasting question_deleted: #{e.class} - #{e.message}"
      # ブロードキャストエラーは無視して処理を続行
    end
  end

  def index
    @conference = Conference.find_by(abbr: event_name)

    @talks = @conference.talks.joins('LEFT JOIN conference_days ON talks.conference_day_id = conference_days.id')
                        .includes([:talks_speakers, :speakers, :talk_category, :track, :conference_day, :proposal, :talk_time])

    if !@conference.cfp_result_visible && !@conference.archived?
      redirect_to(proposals_path)
    end

    # talks of cndt2020 and cndo2021 don't have proposals
    # TODO: Conferenceのステータスを改善した後、適切な条件分岐で修正する
    @talks = if ['cndt2020', 'cndo2021'].include?(@conference.abbr)
               @talks.where(show_on_timetable: true)
             elsif @conference.cfp_result_visible
               @talks.where(show_on_timetable: true,
                            proposals: { status: :accepted })
             else
               # NOTE: Proposal 採択前は conference_days が nil
               @talks.where(show_on_timetable: true,
                            conference_day_id: @conference.conference_days.externals.map(&:id).append(nil))
             end

    @talks.order('conference_days.date ASC').order('talks.start_time ASC')
  end

  helper_method :video_archived?, :document_archived?, :display_video?, :display_document?

  def video_archived?(talk)
    if talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL).present?
      if talk.proposal_items.empty?
        false
      else
        proposal_item = talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL) || []
        proposal_item.proposal_item_configs.map { |config| [VideoAndSlidePublished::ALL_OK, VideoAndSlidePublished::ONLY_VIDEO].include?(config.key.to_i) }.any?
      end
    else
      talk.video_published
    end
  end

  def document_archived?(talk)
    if talk.document_url.present? && talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL).present?
      if talk.proposal_items.empty?
        false
      else
        proposal_item = talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL) || []
        proposal_item.proposal_item_configs.map { |config| [VideoAndSlidePublished::ALL_OK, VideoAndSlidePublished::ONLY_SLIDE].include?(config.key.to_i) }.any?
      end
    else
      false
    end
  end

  def display_video?(talk)
    if (talk.conference.closed? && logged_in?) || (talk.conference.opened? && logged_in?) || talk.conference.archived?
      if talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL).present?
        if talk.proposal_items.empty?
          false
        else
          talk.allowed_showing_video? && talk.archived?
        end
      else
        (talk.video_published && talk.video.present? && talk.archived?)
      end
    else
      false
    end
  end

  def display_document?(talk)
    if (talk.conference.closed? && logged_in?) || (talk.conference.opened? && logged_in?) || talk.conference.archived?
      if talk.document_url.present? && talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL).present?
        if talk.proposal_items.empty?
          false
        else
          proposal_item = talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL) || []
          proposal_item.proposal_item_configs.map { |config| [VideoAndSlidePublished::ALL_OK, VideoAndSlidePublished::ONLY_SLIDE].include?(config.key.to_i) }.any?
        end
      else
        false
      end
    end
  end

  private

  # CFP募集期間中は登壇者登録だけでも表示する
  # CFP期間後はProfileの登録が必要
  def new_user?
    (speaker? && set_conference.speaker_entry_enabled?) || super
  end

  def speaker?
    return false if current_user_model.nil?
    @speaker.present? || Speaker.find_by(user_id: current_user_model.id, conference_id: set_conference.id).present?
  end

  def talk_params
    params.require(:talk).permit(:title, :abstract, :movie_url, :track, :start_time, :end_time, :talk_difficulty_id, :talk_category_id)
  end

  # CFP募集期間中は登壇者登録だけでも表示する
  # CFP期間後はProfileの登録が必要
  def should_redirect?
    super && (!speaker? || !set_conference.speaker_entry_enabled?)
  end

  def talk_start_to_end(talk)
    if talk.start_time.present? && talk.end_time.present?
      talk.start_time.strftime('%H:%M') + '-' + talk.end_time.strftime('%H:%M')
    else
      ''
    end
  end
end
