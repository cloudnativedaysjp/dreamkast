class SpeakerDashboardsController < ApplicationController
  include SecuredSpeaker
  before_action :logged_in_using_omniauth?, :set_speaker

  def show
    @speaker_announcements = @conference.speaker_announcements.find_by_speaker(@speaker.id) unless @speaker.nil?
  end

  def logged_in_using_omniauth?
    if logged_in?
      @current_user = session[:userinfo]
    end
  end

  def set_speaker
    @conference ||= Conference.find_by(abbr: params[:event])
    if @current_user
      @speaker = Speaker.find_by(conference_id: @conference.id, email: @current_user[:info][:email])
      @talks = @speaker ? @speaker.talks.not_sponsor : []
    end
  end
end
