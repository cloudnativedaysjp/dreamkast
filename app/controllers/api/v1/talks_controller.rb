class Api::V1::TalksController < ApplicationController
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
end
