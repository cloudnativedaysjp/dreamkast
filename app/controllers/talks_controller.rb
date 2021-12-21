class TalksController < ApplicationController
  include Secured
  before_action :set_profile, :set_speaker
  helper_method :talk_start_to_end

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end

  def show
    @conference = Conference.find_by(abbr: event_name)
    @talk = Talk.find_by(id: params[:id], conference_id: conference.id)
    raise(ActiveRecord::RecordNotFound) unless @talk
  end

  def index
    @conference = Conference.find_by(abbr: event_name)
    @talks = if @conference.cfp_result_visible
               @conference.talks.joins("LEFT JOIN conference_days ON talks.conference_day_id = conference_days.id").includes(:proposal).where(show_on_timetable: true,
                                                                                                                                              proposals: { status: :accepted }).order("conference_days.date ASC").order("talks.start_time ASC")
             else
               @conference.talks.joins("LEFT JOIN conference_days ON talks.conference_day_id = conference_days.id").includes(:proposal).where(show_on_timetable: true).order("conference_days.date ASC").order("talks.start_time ASC")
             end
  end

  helper_method :display_video?

  def display_video?(talk)
    if (talk.conference.closed? && logged_in?) || (talk.conference.opened? && logged_in?) || talk.conference.archived?
      if talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL).present?
        if talk.proposal_items.empty?
          false
        else
          talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL)&.proposal_item_configs.map { |config| [VideoAndSlidePublished::ALL_OK, VideoAndSlidePublished::ONLY_VIDEO].include?(config.key.to_i) }.any?
        end
      else
        (talk.video_published && talk.video.present? && talk.archived?)
      end
    else
      false
    end
  end

  private


  def talk_params
    params.require(:talk).permit(:title, :abstract, :movie_url, :track, :start_time, :end_time, :talk_difficulty_id, :talk_category_id)
  end

  def set_profile
    if @current_user
      @profile = Profile.find_by(email: @current_user[:info][:email], conference_id: set_conference.id)
    end
  end

  def talk_start_to_end(talk)
    if talk.start_time.present? && talk.end_time.present?
      talk.start_time.strftime("%H:%M") + "-" + talk.end_time.strftime("%H:%M")
    else
      ""
    end
  end
end
