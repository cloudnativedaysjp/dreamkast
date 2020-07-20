class Auth0Controller < ApplicationController
    def callback
      # This stores all the user information that came from Auth0
      # and the IdP
      session[:userinfo] = request.env['omniauth.auth']
  
      # Redirect to the URL you want after successful auth

      ## FIXME: CNDT2020終了後はここについて見直しが必要
      # if request.env['omniauth.origin']
      #   redirect_to "#{request.env['omniauth.origin']}/profiles/talks"
      # else
        redirect_to "/"
      # end
    end
  
    def failure
      # show a failure page or redirect to an error page
      @error_msg = request.params['message']
    end
  end