module SecuredAdmin
    extend ActiveSupport::Concern
  
    included do
      before_action :set_conference, :logged_in_using_omniauth?, :is_admin?, :ensure_admin_profile, if: :use_secured_before_action?
      helper_method :admin?, :speaker?
    end

    def logged_in_using_omniauth?
      if logged_in?
        set_current_user
      else
        redirect_to "/#{params[:event]}"
      end
    end

    def logged_in?
      session[:userinfo].present?
    end

    def admin?
      @current_user[:extra][:raw_info]["https://cloudnativedays.jp/roles"].include?("#{conference.abbr.upcase}-Admin")
    end

    def conference
      @conference ||= Conference.find_by(abbr: event_name)
    end

    def event_name
      params[:event]
    end

    def is_admin?
      raise Forbidden unless admin?
    end

    def set_current_user
      @current_user ||= session[:userinfo]
    end

    def ensure_admin_profile
      @admin_profile ||= AdminProfile.find_by(email: @current_user[:info][:email], conference_id: set_conference.id)

      if admin? && @admin_profile.blank?
            @admin_profile = AdminProfile.new(conference_id: @conference.id)
            @admin_profile.sub = @current_user[:extra][:raw_info][:sub]
            @admin_profile.email = @current_user[:info][:email]

            @admin_profile.save!
      end

      @admin_profile
    end

    private

    def use_secured_before_action?
      true
    end
end
