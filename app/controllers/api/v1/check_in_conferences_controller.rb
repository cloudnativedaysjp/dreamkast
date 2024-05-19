class Api::V1::CheckInConferencesController < ApplicationController
  include SecuredPublicApi
  before_action :set_profile

  skip_before_action :verify_authenticity_token

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

  def create
    @params = check_in_conference_params(JSON.parse(request.body.read, { symbolize_names: true }))
    profile = Profile.find(@params[:profileId])
    check_in_timestamp = Time.zone.at(@params[:check_in_timestamp])
    @check_in = CheckInConference.new(profile:, conference:, check_in_timestamp:)

    if @check_in.save
      render(json: @check_in, status: :created)
    else
      render(json: @check_in.errors, status: :unprocessable_entity)
    end
  end

  def check_in_conference_params(_params)
    json_params = ActionController::Parameters.new(JSON.parse(request.body.read))
    json_params.permit(:profileId, :eventAbbr, :check_in_timestamp)
  end
end
