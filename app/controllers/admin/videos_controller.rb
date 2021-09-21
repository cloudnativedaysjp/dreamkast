class Admin::VideosController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @talks = @conference.talks
  end
end
