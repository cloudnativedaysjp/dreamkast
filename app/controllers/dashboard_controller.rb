class DashboardController < ApplicationController
  include Secured
  include Logging
  
  def show
    @user = session[:userinfo]
  end
end