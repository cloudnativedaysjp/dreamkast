class SponsorDashboards::SponsorDashboardsController < ApplicationController
  include SecuredSponsor
  before_action :set_sponsor_contact

  def show
    @sponsor = Sponsor.find(params[:sponsor_id])

    if logged_in? && @sponsor.present? && @sponsor_contact.present?
      if @sponsor.id == @sponsor_contact.sponsor_id
        @speaker = current_conference.speakers.find_by(user_id: current_user_model.id)
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
    if current_user && current_user_model
      @sponsor_contact = SponsorContact.find_by(conference_id: current_conference.id, user_id: current_user_model.id)
    end
  end
end
