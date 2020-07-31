class EventController < ApplicationController
  
  include Secured
  before_action :set_profile

  def show
    if session[:userinfo].present?
      redirect_to dashboard_path
    end
    @conference = Conference.first
    @sponsor_types = @conference.sponsor_types.order(order: "ASC")
  end
  
  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end
  
  def privacy

  end

  def coc

  end

  private

  def set_profile
    if @current_user
      @profile = Profile.find_by(email: @current_user[:info][:email])
    end
  end
end
