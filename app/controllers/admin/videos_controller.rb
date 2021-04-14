class Admin::VideosController < ApplicationController
  include Secured
  include LogoutHelper

  before_action :is_admin?, :set_conference

  def index
    @talks = @conference.talks
  end
end
