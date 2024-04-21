class SpeakerDashboardsController < ApplicationController
  include SecuredSpeaker
  before_action :set_speaker

  def show
    @speaker_announcements = @conference.speaker_announcements.find_by_speaker(@speaker.id) unless @speaker.nil?
  end

  private

  helper_method :sponsor?

  def sponsor?
    !@conference.sponsors.where('speaker_emails like(?)', "%#{current_user[:info][:email]}%").empty?
  end

  def logged_in_using_omniauth?
    current_user
  end

  def set_speaker
    @conference ||= Conference.find_by(abbr: params[:event])
    if current_user
      @speaker = Speaker.find_by(conference_id: @conference.id, email: current_user[:info][:email])
      @talks = @speaker ? @speaker.talks.not_sponsor : []
    end
  end
end
