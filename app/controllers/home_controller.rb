class HomeController < ApplicationController
  def show
    if session[:userinfo].present?
      redirect_to '/track/1'
    end
  end
end
