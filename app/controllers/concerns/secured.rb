module Secured
  extend ActiveSupport::Concern
  WEBSITE_BASE_URL = 'https://cloudnativedays.jp'.freeze

  included do
    before_action :set_profile, :set_sponsor_contact
    before_action :redirect_to_website
    before_action :to_preparance, :redirect_to_registration, if: :should_redirect?
    before_action :logged_in_using_omniauth?, :to_preparance, if: :use_secured_before_action?
    helper_method :admin?, :speaker?, :beta_user?
  end

  def logged_in_using_omniauth?
    redirect_to('/auth/login?origin=' + request.fullpath) unless logged_in?
  end

  def redirect_to_website
    if set_conference.migrated?
      case [controller_name, action_name]
      in ['talks', 'show']
        redirect_to(URI.join(WEBSITE_BASE_URL, request.fullpath).to_s, allow_other_host: true)
      else
        redirect_to(URI.join(WEBSITE_BASE_URL, params[:event]).to_s, allow_other_host: true)
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

  def new_user?
    return false unless logged_in?
    # If current_user_model is nil (incomplete session), treat as new user
    return true unless current_user_model
    !Profile.find_by(user_id: current_user_model.id, conference_id: set_conference.id)
  end

  def admin?
    return false unless conference && current_user
    roles = current_user.dig(:extra, :raw_info, 'https://cloudnativedays.jp/roles')
    roles&.include?("#{conference.abbr.upcase}-Admin") || false
  end

  def speaker?
    return false unless current_user && conference
    roles = current_user.dig(:extra, :raw_info, 'https://cloudnativedays.jp/roles')
    roles&.include?("#{conference.abbr.upcase}-Speaker") || false
  end

  def beta_user?
    return false unless current_user && conference
    roles = current_user.dig(:extra, :raw_info, 'https://cloudnativedays.jp/roles')
    roles&.include?("#{conference.abbr.upcase}-Beta") || false
  end

  def conference
    @conference ||= Conference.find_by(abbr: event_name)
  end

  def event_name
    params[:event]
  end

  private

  def use_secured_before_action?
    true
  end
end
