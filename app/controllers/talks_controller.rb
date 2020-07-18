class TalksController < ApplicationController
  include Secured
  before_action :set_profile
  before_action :set_talk, only: [:show]

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end
  
  def show
  end

  private
    def set_talk
      @talk = Talk.find(params[:id])
    end

    def talk_params
      params.require(:talk).permit(:title, :abstract, :movie_url, :track, :start_time, :end_time, :talk_difficulty_id, :talk_category_id)
    end

    def set_profile
      if @current_user
        @profile = Profile.find_by(email: @current_user[:info][:email])
      end
    end
end
