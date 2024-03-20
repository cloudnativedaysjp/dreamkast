class LogoutController < ApplicationController
  include LogoutHelper
  def logout
    reset_session
    redirect_to(auth0_logout_url.to_s)
  end
end
