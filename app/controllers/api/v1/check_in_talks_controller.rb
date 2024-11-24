class Api::V1::CheckInTalksController < ApplicationController
  include SecuredAdminApi
  before_action :set_profile

  skip_before_action :verify_authenticity_token

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

  def create
    @params = check_in_talks_params(JSON.parse(request.body.read, { symbolize_names: true }))
    talk = Talk.find(@params[:talkId])
    profile = Profile.find(@params[:profileId])
    check_in_timestamp = Time.zone.at(@params[:checkInTimestamp])
    @check_in = CheckInTalk.new(profile:, talk:, check_in_timestamp:, scanner_profile_id: profile.id)

    if @check_in.save
      render(json: @check_in, status: :created)
    else
      render(json: @check_in.errors, status: :unprocessable_entity)
    end
  end

  def check_in_talks_params(params)
    json_params = ActionController::Parameters.new(params)
    json_params.permit(:eventAbbr, :profileId, :talkId, :checkInTimestamp)
  end
end
