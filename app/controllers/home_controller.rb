class HomeController < ApplicationController
  def show
    @conferences = Conference.all
  end
end
