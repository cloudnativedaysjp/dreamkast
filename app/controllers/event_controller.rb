class EventController < ApplicationController
  def show
    if session[:userinfo].present?
      redirect_to "/#{event_name}/track/1"
    end
  end
end
