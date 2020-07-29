class TimetableController < ApplicationController
  include Secured
  before_action :set_profile

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end

  def index
    @conference = Conference.includes(:talks).find_by(abbr: event_name)
    raise ActiveRecord::RecordNotFound unless @conference

    @talks = Talk.eager_load(:talk_category, :talk_difficulty).all
    @talk_cagetogies = TalkCategory.all
    @talk_difficulties = TalkDifficulty.all
  end

  private

  def set_profile
    if @current_user
      @profile = Profile.find_by(email: @current_user[:info][:email])
    end
  end
end
