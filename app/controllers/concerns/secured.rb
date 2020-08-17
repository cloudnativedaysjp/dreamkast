module Secured
    extend ActiveSupport::Concern
  
    included do
      before_action :logged_in_using_omniauth?, :new_user?
      helper_method :admin?, :speaker?
    end
  
    def logged_in_using_omniauth?
      if session[:userinfo].present?
        @current_user = session[:userinfo]
      else
        redirect_to '/cndt2020'
      end
    end

    def new_user?
      unless ["profiles", "timetable", "speakers", "event", "contents"].include?(controller_name) || controller_path == "talks"
        unless Profile.find_by(email: @current_user[:info][:email])
          redirect_to "/#{params[:event]}/registration"
        end
      end
    end

    def admin?
      @current_user[:extra][:raw_info]["https://cloudnativedays.jp/roles"].include?("CNDT2020-Admin")
    end

    def speaker?
      @current_user[:extra][:raw_info]["https://cloudnativedays.jp/roles"].include?("CNDT2020-Speaker")
    end

    def is_admin?
      # respond_to do |format|
      #   format.html { redirect_to controller: "track", action: "show", id: 1 }
      #   format.json { render json: "Forbidden", status: :forbidden }
      # end
    end
end
