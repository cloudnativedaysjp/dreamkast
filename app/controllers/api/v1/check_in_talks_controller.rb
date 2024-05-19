class Api::V1::CheckInTalksController < ApplicationController
  include SecuredPublicApi
  before_action :set_profile

  skip_before_action :verify_authenticity_token

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

  def create
    talk = Talk.find(check_in_talk_params[:talkId])
    profile = Profile.find(check_in_talk_params[:profileId])
    check_in_timestamp = Time.zone.at(check_in_talk_params[:check_in_timestamp])
    @check_in = CheckInTalk.new(profile:, talk:, check_in_timestamp:)

    if @check_in.save
      render(json: @check_in, status: :created)
    else
      render(json: @check_in.errors, status: :unprocessable_entity)
    end
  end

  def check_in_talk_params
    json_params = ActionController::Parameters.new(JSON.parse(request.body.read))
    json_params.permit(:eventAbbr, :profileId, :talkId, :check_in_timestamp)
  end
end
