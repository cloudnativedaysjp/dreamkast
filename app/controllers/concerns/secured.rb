module Secured
  extend ActiveSupport::Concern
  WEBSITE_BASE_URL = 'https://cloudnativedays.jp'.freeze

  included do
    before_action :redirect_to_website
    before_action :to_preparance, :redirect_to_registration, if: :should_redirect?
    before_action :logged_in_using_omniauth?, :to_preparance, if: :use_secured_before_action?
    helper_method :admin?, :speaker?, :beta_user?
  end

  def logged_in_using_omniauth?
    if logged_in?
      set_current_user
    else
      redirect_to('/auth/login?origin=' + request.fullpath)
    end
  end

  def redirect_to_website
    if set_conference.migrated?
      case [controller_name, action_name]
      in ['talks', 'show']
        redirect_to(URI.join(WEBSITE_BASE_URL, request.fullpath).to_s)
      else
        redirect_to(URI.join(WEBSITE_BASE_URL, params[:event]).to_s)
      end
    end
  end

  def to_preparance
    # ログイン状態
    # かつカンファレンスが一般参加応募不可状態
    redirect_to(preparation_url) if conference.attendee_entry_disabled? && logged_in?
  end

  def should_redirect?
    new_user? && !set_conference.archived?
  end

  def redirect_to_registration
    redirect_to("/#{params[:event]}/registration") unless ['profiles'].include?(controller_name)
  end

  def logged_in?
    session[:userinfo].present?
  end

  def new_user?
    logged_in? && !Profile.find_by(email: set_current_user[:info][:email], conference_id: set_conference.id)
  end

  def admin?
    @current_user[:extra][:raw_info]['https://cloudnativedays.jp/roles'].include?("#{conference.abbr.upcase}-Admin")
  end

  def speaker?
    @current_user[:extra][:raw_info]['https://cloudnativedays.jp/roles'].include?("#{conference.abbr.upcase}-Speaker")
  end

  def beta_user?
    @current_user[:extra][:raw_info]['https://cloudnativedays.jp/roles'].include?("#{conference.abbr.upcase}-Beta")
  end

  def conference
    @conference ||= Conference.find_by(abbr: event_name)
  end

  def event_name
    params[:event]
  end

  def set_current_user
    current_user
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
