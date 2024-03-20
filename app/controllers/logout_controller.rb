class LogoutController < ApplicationController
  def logout
    reset_session
    redirect_to(auth0_logout_url)
  end

  private

  def auth0_logout_url
    domain = ENV['AUTH0_DOMAIN']
    client_id = ENV['AUTH0_CLIENT_ID']
    request_params = {
      returnTo: root_url,
      client_id:
    }

    URI::HTTPS.build(host: domain, path: '/v2/logout', query: request_params.to_query).to_s
  end
end
