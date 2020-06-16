module Secured
    extend ActiveSupport::Concern
  
    included do
      before_action :logged_in_using_omniauth?
    end
  
    def logged_in_using_omniauth?
      if session[:userinfo].present?
        @current_user = session[:userinfo]
      else
        redirect_to '/'
      end
    end
end