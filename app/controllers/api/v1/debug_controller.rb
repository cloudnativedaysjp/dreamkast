class Api::V1::DebugController < ApplicationController
  include SecuredPublicApi
  before_action :authenticate_request!, only: [:index]

  skip_before_action :verify_authenticity_token

  def index
    render(:index, formats: :json, type: :jbuilder)
  end
end
