class TalksController < ApplicationController
  include Secured
  before_action :set_profile
  helper_method :talk_start_to_end

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end
  
  def show
    @conference = Conference.find_by(abbr: event_name)
    @talk = Talk.find_by(id: params[:id], conference_id: conference.id)
    raise ActiveRecord::RecordNotFound unless @talk
  end

  def index
    @conference = Conference.find_by(abbr: event_name)
    @talks = @conference.talks.where(show_on_timetable: true).order('date ASC').order('start_time ASC')
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
      ''
    end
  end
end
