module ApplicationHelper
  def current_user
    return unless session[:userinfo]
    @current_user ||= session[:userinfo]
  end

  def logged_in?
    !!session[:userinfo]
  end

  def authenticate
    return if logged_in?
    redirect_to root_path, alert: 'ログインしてください'
  end
end
