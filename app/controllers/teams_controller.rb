class TeamsController < ApplicationController

  before_action :set_conference
  def show
    @admin_profiles = @conference.admin_profiles.order(name: 'ASC')
  end
end
