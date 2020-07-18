class TracksController < ApplicationController

  def index
    @current = Video.where(on_air: true)
  end

end
