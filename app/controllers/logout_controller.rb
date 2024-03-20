class LogoutController < ApplicationController
  include LogoutHelper
  def logout
    reset_session
    redirect_to(auth0_logout_url)
  end
end
