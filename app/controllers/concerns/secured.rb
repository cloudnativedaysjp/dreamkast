module Secured
    extend ActiveSupport::Concern
  
    included do
      before_action :logged_in_using_omniauth?, :new_user?
    end
  
    def logged_in_using_omniauth?
      if session[:userinfo].present?
        @current_user = session[:userinfo]
      else
        redirect_to '/'
      end
    end

    def new_user?
      if Profile.find_by(email: @current_user[:email])
        redirect_to '/registration'
      end
    end
end