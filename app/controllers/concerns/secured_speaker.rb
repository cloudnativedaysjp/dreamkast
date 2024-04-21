module SecuredSpeaker
  extend ActiveSupport::Concern

  included do
    before_action :logged_in_using_omniauth?
    helper_method :admin?, :speaker?
  end

  def logged_in_using_omniauth?
    redirect_to("/#{params[:event]}/speaker_dashboard") unless logged_in?
  end

  def logged_in?
    session[:userinfo].present?
  end

  def admin?
    current_user[:extra][:raw_info]['https://cloudnativedays.jp/roles'].include?("#{@conference.abbr.upcase}-Admin")
  end

  def speaker?
    current_user[:extra][:raw_info]['https://cloudnativedays.jp/roles'].include?("#{@conference.abbr.upcase}-Speaker")
  end

  def prepare_create
    redirect_to("/#{params[:event]}/speakers/guidance") unless logged_in?
  end
end
