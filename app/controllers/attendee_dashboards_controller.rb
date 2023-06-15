class AttendeeDashboardsController < ApplicationController
  include Secured
  include SponsorHelper
  before_action :set_profile, :set_speaker

  def show
    @conference = Conference.includes(:talks).find_by(abbr: event_name)
    if @conference.opened?
      redirect_to(tracks_path)
    end

    @announcements = @conference.announcements.published
    @speaker_announcements = @conference.speaker_announcements.find_by_speaker(@speaker.id) unless @speaker.nil?
    @talks = @conference.talks.eager_load(:talk_category, :talk_difficulty).all
    @talk_categories = @conference.talk_categories
    @talk_difficulties = @conference.talk_difficulties
    @booths = @conference.booths.published
  end
end
