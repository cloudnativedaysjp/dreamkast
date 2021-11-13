class TimetableController < ApplicationController
  include Secured
  before_action :set_profile, :set_speaker

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end

  def index
    @conference = Conference.includes(conference_days: :talks).includes(talks: :track).find_by(abbr: event_name)
    @talks = @conference.talks.includes(:track).eager_load(:talk_category, :talk_difficulty).where(show_on_timetable: true)
    @talk_categories = TalkCategory.where(conference_id: @conference.id)
    @talk_difficulties = TalkDifficulty.where(conference_id: @conference.id)

    @params = params
  end

  private

  helper_method :timetable_partial_name

  def set_profile
    if @current_user
      @profile = Profile.find_by(email: @current_user[:info][:email], conference_id: set_conference.id)
    end
  end

  def timetable_partial_name
    if @params[:event] == "cndt2020"
      "timetable"
    else
      "timetable_#{@params[:event]}"
    end
  end
end
