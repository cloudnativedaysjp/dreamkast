class TalksController < ApplicationController
  include Secured
  before_action :set_profile, :set_speaker
  helper_method :talk_start_to_end

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end

  # - プロポーザルの採択結果を表示する場合
  #   - プロポーザルが採択されている場合：セッション情報を表示する
  #   - プロポーザルが採択されていない場合：404を返す
  # - プロポーザルの採択結果を表示しない場合：404を返す
  # - Conferenceのstatusが `migrated` の場合：websiteにリダイレクトする
  def show
    @conference = Conference.find_by(abbr: event_name)
    @talk = Talk.find_by(id: params[:id], conference_id: conference.id)

    unless @conference.cfp_result_visible
      raise(ActiveRecord::RecordNotFound)
    end

    if @conference.cfp_result_visible && @talk.proposal.rejected?
      raise(ActiveRecord::RecordNotFound)
    end

    raise(ActiveRecord::RecordNotFound) unless @talk
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
                            conference_day_id: @conference.conference_days.externals.map(&:id),
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
    return false if @current_user.nil?
    Speaker.find_by(email: @current_user[:info][:email], conference_id: set_conference.id).present?
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
