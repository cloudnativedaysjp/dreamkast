class Api::V1::ProfilesController < ApplicationController
  include SecuredApi
  before_action :set_profile

  def my_profile
    render(:my_profile, formats: :json, type: :jbuilder)
  end
end
