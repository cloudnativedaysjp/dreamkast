module Secured
    extend ActiveSupport::Concern
  
    included do
      before_action :logged_in_using_omniauth?, :new_user?, if: :use_secured_before_action?
      helper_method :admin?, :speaker?
    end

    def logged_in_using_omniauth?
      if session[:userinfo].present?
        @current_user = session[:userinfo]
      else
        redirect_to "/#{params[:event]}"
      end
    end

    def new_user?
      if session[:userinfo].present? && !Profile.find_by(email: @current_user[:info][:email])
        unless ["profiles"].include?(controller_name)
          redirect_to "/#{params[:event]}/registration"
        end
      end
    end

    def admin?
      @current_user[:extra][:raw_info]["https://cloudnativedays.jp/roles"].include?("#{conference.abbr.upcase}-Admin")
    end

    def speaker?
      @current_user[:extra][:raw_info]["https://cloudnativedays.jp/roles"].include?("#{conference.abbr.upcase}-Speaker")
    end

    def conference
      @conference ||= Conference.find_by(abbr: event_name)
    end

    def event_name
      params[:event]
    end

    def is_admin?
      # respond_to do |format|
      #   format.html { redirect_to controller: "track", action: "show", id: 1 }
      #   format.json { render json: "Forbidden", status: :forbidden }
      # end
    end

    private

    def use_secured_before_action?
      true
    end
end
