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
      @message_box = "#{Conference.find(1).name}へようこそ"
      cls = "d-none"
    end
    return "<div id=\"message_box\" class=\"#{cls}\"><p>#{@message_box}</p></div>"
  end

  def full_title(page_title = '')
    base_title = Conference.find(1).name
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def full_title(page_title = '')
    base_title = 'CloudNative Days Tokyo 2020'
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def full_url(path)
    domain = if Rails.env.development?
               'http://0.0.0.0:3000'
             else
               'https://event.cloudnativedays.jp/cndt2020'
             end
    "#{domain}#{path}"
  end
end
