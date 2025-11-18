class Api::V1::TalksController < ApplicationController
  include SecuredPublicApi

  skip_before_action :authenticate_request!, only: [:index, :show]
  skip_before_action :verify_authenticity_token

  def index
    conference = Conference.find_by(abbr: params[:eventAbbr])
    query = { conference_id: conference.id }
    query[:track_id] = params[:trackId] if params[:trackId]
    @talks = Talk
      .includes(:conference, :conference_day, :talk_time, :talk_difficulty, :talk_category, :talks_speakers, :video, :speakers, registered_talks: :profile)
      .accepted_and_intermission
      .where(query)
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
    @talk = Talk.find(params[:id])
    conference = @talk.conference
    body = JSON.parse(request.body.read, { symbolize_names: true })
    if body[:on_air].nil?
      render_400
    else
      if body[:on_air]
        @current_on_air_videos = Video.includes(talk: :conference).where(talks: { conference_id: conference.id }, on_air: true)
        ActiveRecord::Base.transaction do
          # Disable onair of all talks that are onair
          @current_on_air_videos.each do |video|
            video.update!(on_air: false)
          end

          # Update the current talk to onair
          @talk.video.update!(on_air: true)
        end

      else
        @talk.video.update!(on_air: false)
      end
      ActionCable.server.broadcast(
        "on_air_#{conference.abbr}", Video.on_air_v2(conference.id)
      )
      render(json: { message: 'OK' }, status: 200)
    end
  end
end
