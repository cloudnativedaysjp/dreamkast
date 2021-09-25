class TeamsController < ApplicationController

  before_action :set_conference
  def show
    @admin_profiles = @conference.admin_profiles.where(show_on_team_page: true).order(name: 'ASC')
  end
end
