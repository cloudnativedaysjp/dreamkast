class TimetableController < ApplicationController
  include Secured
  before_action :set_profile

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end

  def index
    @conference = Conference.includes(conference_days: :talks).includes(talks: :track).find_by(abbr: event_name)
    @talks = @conference.talks.includes(:track).eager_load(:talk_category, :talk_difficulty).where(show_on_timetable: true)
    @talk_cagetogies = TalkCategory.all
    @talk_difficulties = TalkDifficulty.all

    @params = params
  end

  private

  def set_profile
    if @current_user
      @profile = Profile.find_by(email: @current_user[:info][:email])
    end
  end
end
