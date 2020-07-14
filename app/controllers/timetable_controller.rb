class TimetableController < ApplicationController
  include Secured
  before_action :set_profile

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end

  def index
    @conference = Conference.includes(:talks, {talks: :speakers}).find_by(abbr: event_name)
  end

  def talks_checked?(talk_id)
    if @profile
      @profile.talks.select{|talk| talk.id == talk_id}.present?
    else
      false
    end
  end

  helper_method :talks_checked?

  private

  def set_profile
    if @current_user
      @profile = Profile.find_by(email: @current_user[:info][:email])
    end
  end
end
