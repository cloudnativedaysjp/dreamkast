class Api::V1::CheckInConferencesController < ApplicationController
  include SecuredAdminApi
  before_action :set_profile

  skip_before_action :verify_authenticity_token

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

  def create
    @params = check_in_conferences_params(JSON.parse(request.body.read, { symbolize_names: true }))
    attendee = Profile.find(@params[:profileId])
    speaker = Speaker.find_by(email: attendee.email, conference_id: conference.id)
    check_in_timestamp = Time.zone.at(@params[:checkInTimestamp])
    @check_in = CheckInConference.new(profile: attendee, conference:, check_in_timestamp:, scanner_profile_id: @profile.id)
    conference = Conference.find_by(abbr: @params[:eventAbbr])
    if @params[:printerId].present?
      GenerateEntrysheetJob.perform_now(conference.id, attendee.id, speaker&.id, @params[:printerId])
    end

    if @check_in.save
      render(json: @check_in, status: :created)
    else
      render(json: @check_in.errors, status: :unprocessable_entity)
    end
  end

  def check_in_conferences_params(params)
    json_params = ActionController::Parameters.new(params)
    json_params.permit(:profileId, :eventAbbr, :checkInTimestamp, :printerId)
  end
end
