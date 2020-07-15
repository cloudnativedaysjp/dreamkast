class EventController < ApplicationController
  def show
    if session[:userinfo].present?
      redirect_to profiles_talks_path
    end
  end

  
  def privacy

  end

  def coc

  end
end
