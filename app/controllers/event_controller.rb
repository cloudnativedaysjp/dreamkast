class EventController < ApplicationController
  include ActionView::Helpers::UrlHelper

  include Secured
  before_action :set_profile

  def show
    @conference = Conference.includes(sponsor_types: {sponsors: :sponsor_attachment_logo_image}).order("sponsor_types.order ASC").find_by(abbr: event_name)
    if session[:userinfo].present?
      if @conference.opened?
        redirect_to tracks_path
      else
        redirect_to dashboard_path
      end
    end
  end
  
  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end
  
  def privacy
    @conference = Conference.find_by(abbr: params[:event])
  end

  def coc
    @conference = Conference.find_by(abbr: params[:event])
  end

  def sponsor_logo_class(sponsor_type)
    case sponsor_type.name
    when "Diamond", "Special Collaboration"
      "col-12 col-md-4 my-3 m-md-3"
    when "Platinum"
      "col-12 col-md-3 my-3 m-md-3"
    when "Gold", "Booth", "Mini Session", "CM", "Tool"
      "col-12 col-md-2 my-3 m-md-3"
    else
      "col-12 col-md-3 my-3 m-md-3"
    end
  end

  helper_method :sponsor_logo_class, :days
  private

  def days
    day_of_the_week = %w(月 火 水 木 金 土 日)
    d = @conference.conference_days.where(internal: false)
    if d.length == 1
      day = day_of_the_week[d.first.date.cwday - 1]
      return d.first.date.strftime("%Y年%m月%d日") + "(#{day})"
    else
      first = d.order(:date).first
      fday = day_of_the_week[first.date.cwday - 1]
      last = d.order(:date).last
      lday = day_of_the_week[last.date.cwday - 1]
      return "#{first.date.strftime("%Y年%m月%d日")}(#{fday})〜#{last.date.strftime("%Y年%m月%d日")}(#{lday})"
    end
  end

  def set_profile
    if @current_user
      @profile = Profile.find_by(email: @current_user[:info][:email])
    end
  end
end
