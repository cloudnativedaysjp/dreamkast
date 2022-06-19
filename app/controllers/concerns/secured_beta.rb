module SecuredBeta
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user, :is_beta_user?
    # helper_method :beta_user?
  end
  def beta_user?
    @current_user[:extra][:raw_info]['https://cloudnativedays.jp/roles'].include?("#{conference.abbr.upcase}-Beta")
  end

  def is_beta_user?
    raise(NotFound) unless beta_user? || admin?
  end

  def set_current_user
    @current_user ||= session[:userinfo]
  end

  def admin?
    @current_user[:extra][:raw_info]['https://cloudnativedays.jp/roles'].include?("#{conference.abbr.upcase}-Admin")
  end
end
