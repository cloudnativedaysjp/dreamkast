class HomeController < ApplicationController
  def show
    @events = Conference.all
  end

end
