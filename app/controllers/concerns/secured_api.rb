module SecuredApi
    extend ActiveSupport::Concern
  
    included do
      before_action :logged_in_using_omniauth?
    end

    def logged_in_using_omniauth?
      if logged_in?
        set_current_user
      else
        raise Forbidden
      end
    end

    private

    def logged_in?
      session[:userinfo].present?
    end

    def set_current_user
      @current_user ||= session[:userinfo]
    end
end
