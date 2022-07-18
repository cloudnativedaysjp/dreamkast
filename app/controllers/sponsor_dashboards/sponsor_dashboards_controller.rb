class SponsorDashboards::SponsorDashboardsController < ApplicationController
  include SecuredSponsor
  before_action :logged_in_using_omniauth?, :set_sponsor_profile

  def show
    @sponsor = Sponsor.find(params[:sponsor_id])
    unless logged_in? && @sponsor.present? && @sponsor_profile.present?
      redirect_to(sponsor_dashboards_login_path)
    else
      @speaker = @conference.speakers.find_by(email: @current_user[:info][:email])
      @talks = @speaker ? @speaker.talks.sponsor : []
    end
  end

  def login
    if logged_in?
      @sponsor = Sponsor.where(conference_id: @conference.id).where('speaker_emails like(?)', "%#{@current_user[:info][:email]}%").first
      if @sponsor.nil?
        raise(Forbidden)
      elsif logged_in? && @sponsor.present? && @sponsor_profile.nil?
        redirect_to(new_sponsor_dashboards_sponsor_profile_path(sponsor_id: @sponsor.id))
      elsif logged_in? && @sponsor.present? && @sponsor_profile.present?
        redirect_to(sponsor_dashboards_path(sponsor_id: @sponsor.id))
      end
    end
  end

  private

  def logged_in_using_omniauth?
    if logged_in?
      @current_user = session[:userinfo]
    end
  end

  def set_sponsor_profile
    @conference ||= Conference.find_by(abbr: params[:event])
    if @current_user
      @sponsor_profile = SponsorProfile.find_by(conference_id: @conference.id, email: @current_user[:info][:email])
    end
  end
end
