class DashboardController < ApplicationController
  include Secured
  before_action :set_profile

  def show
    @conference = Conference.includes(:talks).find_by(abbr: event_name)
    @talks = Talk.eager_load(:talk_category, :talk_difficulty).all
    @talk_cagetogies = TalkCategory.all
    @talk_difficulties = TalkDifficulty.all
  end

  private

  def set_profile
    @profile = Profile.find_by(email: @current_user[:info][:email])
  end
end