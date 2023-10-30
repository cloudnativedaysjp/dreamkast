class ContentsController < ApplicationController
  include Secured
  before_action :set_profile, :set_speaker

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end

  def index
  end

  def discussion
    @conference = Conference.find_by(abbr: params[:event])
    render("#{@conference.abbr}_discussion".to_sym)
  end

  def kontest
    @conference = Conference.find_by(abbr: params[:event])
  end

  def hands_on
    @conference = Conference.find_by(abbr: params[:event])
    render("#{@conference.abbr}_hands_on".to_sym)
  end

  def job_board
    @conference = Conference.find_by(abbr: params[:event])
    render("#{@conference.abbr}_job_board".to_sym)
  end

  def o11y
    @conference = Conference.find_by(abbr: params[:event])
    render(:o11y)
  end

  def community_lt
    @conference = Conference.find_by(abbr: params[:event])
    render("contents/#{@conference.abbr}/community_lt")
  end
end
