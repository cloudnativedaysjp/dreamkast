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

  def message_box
    cls = ""
    unless @message_box
      @message_box = "CloudNative Days 2020へようこそ"
      cls = "d-none"
    end
    return "<div id=\"message_box\" class=\"#{cls}\"><p>#{@message_box}</p></div>"
  end

  def full_title(page_title = '')
    base_title = "CloudNative Days 2020"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
end
