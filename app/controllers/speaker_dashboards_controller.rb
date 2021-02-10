class SpeakerDashboardsController < ApplicationController
  include SecuredSpeaker
  before_action :logged_in_using_omniauth?, :set_speaker

  def show
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
    end
  end

  private

  helper_method :video_url

  def video_url(talk)
    if talk.video.present?
      "/#{params[:event]}/speaker_dashboard/videos/#{talk.video.id}/edit"
    else
      "/#{params[:event]}/speaker_dashboard/videos/new?talk_id=#{talk.id}"
    end
  end
end
