class HomeController < ApplicationController
  include HomeHelper
  def show
    @upcoming = Conference.merge(Conference.where(status: 0).or(Conference.where(status: 1)))
    @archived = Conference.merge(Conference.where(status: 2).or(Conference.where(status: 3)))
  end
end
