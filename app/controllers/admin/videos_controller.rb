class Admin::VideosController < ApplicationController
  include SecuredAdmin

  def index
    @talks = @conference.talks
  end
end
