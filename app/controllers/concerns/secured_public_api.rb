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
    @current_user[:extra] = {}
    @current_user[:extra][:raw_info] = {}
    @current_user[:info] = {}
    @current_user[:extra][:raw_info] = claim
    if @current_user[:extra][:raw_info]['name'].present?
      @current_user[:info][:name] = @current_user[:extra][:raw_info]['name']
      @current_user[:info][:nickname] = @current_user[:extra][:raw_info]['nickname']
      @current_user[:info][:email] = @current_user[:extra][:raw_info]['email']
      @current_user[:info][:image] = @current_user[:extra][:raw_info]['picture']
    end
    @current_user
  end
end
