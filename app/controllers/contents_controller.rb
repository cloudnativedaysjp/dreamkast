class ContentsController < ApplicationController
  include Secured
  before_action :set_profile, :set_speaker

  def logged_in_using_omniauth?
    current_user
  end

  def index
  end

  def discussion
    @conference = Conference.find_by(abbr: params[:event])
    render(:"#{@conference.abbr}_discussion")
  end

  def kontest
    @conference = Conference.find_by(abbr: params[:event])
  end

  def hands_on
    @conference = Conference.find_by(abbr: params[:event])
    render(:"#{@conference.abbr}_hands_on")
  end

  def job_board
    @conference = Conference.find_by(abbr: params[:event])
    render(:"#{@conference.abbr}_job_board")
  end

  def o11y
    @conference = Conference.find_by(abbr: params[:event])
    render(:o11y)
  end

  def community_lt
    @conference = Conference.find_by(abbr: params[:event])
    render("contents/#{@conference.abbr}/community_lt")
  end

  def yurucafe
    @conference = Conference.find_by(abbr: params[:event])
    render("contents/#{@conference.abbr}/yurucafe")
  end

  def stamprally
    @conference = Conference.find_by(abbr: params[:event])
    render("contents/#{@conference.abbr}/stamprally")
  end
end
