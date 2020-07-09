class EventController < ApplicationController
  def show
    if session[:userinfo].present?
      redirect_to '/cndt2020/track/1'
    end
  end
end
