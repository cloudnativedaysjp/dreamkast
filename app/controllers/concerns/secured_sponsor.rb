module SecuredSponsor
  extend ActiveSupport::Concern

  included do
    before_action :logged_in_using_omniauth?, :set_conference
    helper_method :admin?, :speaker?
  end

  def logged_in_using_omniauth?
    redirect_to("/#{params[:event]}/sponsor_dashboards/login") unless logged_in?
  end

  def admin?
    current_user[:extra][:raw_info]['https://cloudnativedays.jp/roles'].include?("#{current_conference.abbr.upcase}-Admin")
  end

  def speaker?
    current_user[:extra][:raw_info]['https://cloudnativedays.jp/roles'].include?("#{current_conference.abbr.upcase}-Speaker")
  end
end
