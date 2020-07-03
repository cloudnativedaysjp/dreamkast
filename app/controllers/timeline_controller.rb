class TimelineController < ApplicationController
  def index
    @talks = Talk.all
  end
end
