module SecuredSpeaker
  extend ActiveSupport::Concern

  included do
    before_action :logged_in_using_omniauth?
    helper_method :admin?, :speaker?
  end
  
  def logged_in_using_omniauth?
    if logged_in?
      set_current_user
    else
      redirect_to "/#{params[:event]}/speaker_dashboard"
    end
  end

  def set_current_user
    @current_user = session[:userinfo]
  end

  def logged_in?
    session[:userinfo].present?
  end

  def admin?
    @current_user[:extra][:raw_info]["https://cloudnativedays.jp/roles"].include?("CNDT2020-Admin")
  end

  def speaker?
    @current_user[:extra][:raw_info]["https://cloudnativedays.jp/roles"].include?("CNDT2020-Speaker")
  end
end
