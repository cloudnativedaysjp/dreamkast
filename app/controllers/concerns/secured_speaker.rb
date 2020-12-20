module SecuredSpeaker
  extend ActiveSupport::Concern

  included do
    before_action :logged_in_using_omniauth?
  end
  
  def logged_in_using_omniauth?
    if logged_in?
      @current_user = session[:userinfo]
    else
      redirect_to "/#{params[:event]}/speaker_dashboard"
    end
  end

  def logged_in?
    session[:userinfo].present?
  end
end
