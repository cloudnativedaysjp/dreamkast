class SpeakerDashboardsController < ApplicationController
  include SecuredSpeaker
  before_action :set_speaker

  def show
    @talks = @speaker ? @speaker.talks.not_sponsor : []
    @speaker_announcements = @conference.speaker_announcements.find_by_speaker(@speaker.id) unless @speaker.nil?
  end

  private

  helper_method :sponsor?

  def sponsor?
    @conference.sponsor_contacts.where(email: current_user[:info][:email]).present?
  end

  def logged_in_using_omniauth?
    current_user
  end
end
