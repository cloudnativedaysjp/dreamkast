# frozen_string_literal: true

module SecuredPublicApi
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    claim = verify_token
    current_user(claim[0])
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

  def current_user(claim)
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
end
