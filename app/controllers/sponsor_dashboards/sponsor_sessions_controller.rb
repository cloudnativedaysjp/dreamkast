class SponsorDashboards::SponsorSessionsController < ApplicationController
  include SecuredSponsor

  def index
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id])
    @sponsor_contacts = @sponsor.sponsor_contacts
    @sponsor_sessions = @sponsor.talks
  end
end
