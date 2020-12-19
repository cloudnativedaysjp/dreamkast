module Secured
    extend ActiveSupport::Concern
  
    included do
      before_action :logged_in_using_omniauth?, :new_user?
      helper_method :admin?, :speaker?
    end
  
    def logged_in_using_omniauth?
      p action_name
      if logged_in?
        @current_user = session[:userinfo]
      end

      if controller_name == 'speakers'
        if !logged_in? && ["speakers"].include?(controller_name)
          puts "redirect_to /auth/auth0"
          redirect_to "/auth/auth0"
        end

        if new_user? && !speakers_new? && !speakers_create?
          puts "redirect_to /#{params[:event]}/speakers/registration"
          redirect_to "/#{params[:event]}/speakers/registration"
        end
      else

        unless logged_in?
          puts "redirect_to /#{params[:event]}"
          redirect_to "/#{params[:event]}"
        end
      end

    end

    def new_user?
      if session[:userinfo].present? && !Profile.find_by(email: @current_user[:info][:email])
        unless ["profiles"].include?(controller_name)
          redirect_to "/#{params[:event]}/registration"
        end
      end
    end

    def speakers_new?
      controller_name == 'speakers' && action_name == 'new'
    end

    def speakers_create?
      controller_name == 'speakers' && action_name == 'create'
    end

    def admin?
      @current_user[:extra][:raw_info]["https://cloudnativedays.jp/roles"].include?("CNDT2020-Admin")
    end

    def speaker?
      @current_user[:extra][:raw_info]["https://cloudnativedays.jp/roles"].include?("CNDT2020-Speaker")
    end

    def logged_in?
      session[:userinfo].present?
    end

    def is_admin?
      # respond_to do |format|
      #   format.html { redirect_to controller: "track", action: "show", id: 1 }
      #   format.json { render json: "Forbidden", status: :forbidden }
      # end
    end
end
