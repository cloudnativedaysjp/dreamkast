# frozen_string_literal: true

module SecuredPublicApi
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    claim = verify_token
    set_current_user_from_claim(claim[0])
  rescue JWT::VerificationError, JWT::DecodeError
    render(json: { errors: ['Not Authenticated'] }, status: :unauthorized)
  end

  def http_token
    if request.headers['Authorization'].present?
      request.headers['Authorization'].split.last
    end
  end

  def verify_token
    JsonWebToken.verify(http_token)
  end

  def set_current_user_from_claim(claim) # rubocop:disable Naming/AccessorMethodName
    @current_user = {}
    @current_user[:info] = {}
    @current_user[:extra] = {}
    @current_user[:extra][:raw_info] = claim
    if claim['https://cloudnativedays.jp/userinfo'].present?
      userinfo = claim['https://cloudnativedays.jp/userinfo']
      @current_user[:info][:name] = userinfo['name']
      @current_user[:info][:nickname] = userinfo['nickname']
      @current_user[:info][:email] = userinfo['email']
      @current_user[:info][:image] = userinfo['picture']
    end
    @current_user
  end

  def conference
    @conference ||= Conference.find_by(abbr: params[:eventAbbr] || params[:event])
  end

  def set_conference
    conference
  end

  def current_user_model
    return nil unless @current_user
    symbolized_current_user = @current_user.deep_symbolize_keys
    return nil unless symbolized_current_user[:extra] && symbolized_current_user[:extra][:raw_info] && symbolized_current_user[:extra][:raw_info][:sub]
    @current_user_model ||= User.find_or_create_by_auth0_info(
      sub: symbolized_current_user[:extra][:raw_info][:sub],
      email: symbolized_current_user[:info][:email]
    )
  end

  def profile
    @profile ||= Profile.find_by(user_id: current_user_model&.id, conference_id: conference.id)
  end
end
