class Api::V1::ProfilesController < ApplicationController
  include SecuredPublicApi
  before_action :set_profile

  skip_before_action :verify_authenticity_token

  def my_profile
    return head :not_found if @profile.nil?

    render(:my_profile, formats: :json, type: :jbuilder)
  end
end
