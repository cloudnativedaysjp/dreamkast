class Api::V1::TalksController < ApplicationController
  include SecuredPublicApi
  before_action :authenticate_request!, only: [:update]

  skip_before_action :verify_authenticity_token

  def index
    conference = Conference.find_by(abbr: params[:eventAbbr])
    query = { conference_id: conference.id }
    query[:track_id] = params[:trackId] if params[:trackId]
    @talks = Talk.where(query)
    if params[:conferenceDayIds]
      @talks = @talks.where(params[:conferenceDayIds].split(',').map { |id| "conference_day_id = #{id}" }.join(' OR '))
    end
    render(:index, formats: :json, type: :jbuilder)
  end

  def show
    @talk = Talk.find(params[:id])
    render(:show, formats: :json, type: :jbuilder)
  end

  def update
    talk = Talk.find(params[:id])
    body = JSON.parse(request.body.read, { symbolize_names: true })
    if body[:on_air].nil?
      render_400
    else
      if body[:on_air]
        talk.start_streaming
      else
        talk.stop_streaming
      end
      render(json: { message: 'OK' }, status: 200)
    end
  end
end
