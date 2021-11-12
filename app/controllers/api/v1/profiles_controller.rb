class Api::V1::ProfilesController < ApplicationController
  include SecuredApi
  before_action :set_profile

  def my_profile
    render("api/v1/profiles/my_profile.json.jbuilder")
  end
end
