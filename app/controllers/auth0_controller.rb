class Auth0Controller < ApplicationController
  def callback
    # This stores all the user information that came from Auth0
    # and the IdP
    session[:userinfo] = request.env['omniauth.auth']

    # Redirect to the URL you want after successful auth

    if request.env['omniauth.origin']
      uri = URI.parse(request.env['omniauth.origin'])
      uri.query = if uri.params.nil?
                    "state=#{params[:state]}"
                  else
                    "#{uri.query}&state=#{params[:state]}"
                  end
      redirect_to(uri.to_s)
    else
      redirect_to('/')
    end
  end

  def failure
    # show a failure page or redirect to an error page
    redirect_to('/')
  end

  def login
  end
end
