class SponsorDashboards::SponsorDashboardsController < ApplicationController
  include SecuredSponsor
  before_action :set_sponsor_contact

  def show
    @sponsor = Sponsor.find(params[:sponsor_id])

    if logged_in? && @sponsor.present? && @sponsor_contact.present?
      if @sponsor.id == @sponsor_contact.sponsor_id
        @speaker = @conference.speakers.find_by(email: current_user[:info][:email])
        @talks = @speaker ? @speaker.talks.sponsor : []
      else
        render_404
      end
    else
      redirect_to(auth_login_path(origin: request.fullpath))
    end
  end

  private

  helper_method :sponsor?

  def sponsor?
    false
  end

  def logged_in_using_omniauth?
    current_user
  end

  def set_sponsor_contact
    @conference ||= Conference.find_by(abbr: params[:event])
    if current_user
      @sponsor_contact = SponsorContact.find_by(conference_id: @conference.id, email: current_user[:info][:email])
    end
  end
end
