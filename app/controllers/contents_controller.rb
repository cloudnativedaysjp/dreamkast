class ContentsController < ApplicationController
  include Secured
  before_action :set_profile

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end

  def index
  end

  def discussion
    @conference = Conference.find_by(abbr: params[:event])
  end

  def kontest
    @conference = Conference.find_by(abbr: params[:event])
  end

  private
    def set_profile
      if @current_user
        @profile = Profile.find_by(email: @current_user[:info][:email])
      end
    end
end
