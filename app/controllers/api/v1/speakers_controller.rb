class Api::V1::SpeakersController < ApplicationController
  include SecuredPublicApi

  skip_before_action :authenticate_request!, only: [:index]
  skip_before_action :verify_authenticity_token

  def index
    @speakers = current_conference.speakers
    render(:index, formats: :json, type: :jbuilder)
  end
end
