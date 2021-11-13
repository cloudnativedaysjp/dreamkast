class TeamsController < ApplicationController
  include Secured
  before_action :set_conference, :set_profile, :set_speaker

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end

  def show
    @admin_profiles = @conference.admin_profiles.where(show_on_team_page: true).order(name: "ASC")
  end
end
