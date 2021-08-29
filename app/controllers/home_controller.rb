class HomeController < ApplicationController
  include HomeHelper
  def show
    @upcoming = Conference.upcoming
    @previous = Conference.previous
  end
end
