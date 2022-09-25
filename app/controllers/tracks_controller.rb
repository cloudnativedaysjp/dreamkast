class TracksController < ApplicationController
  include Secured
  include SponsorHelper
  before_action :set_profile, :set_speaker

  def index
    @conference = Conference.includes(:talks).find_by(abbr: event_name)
    if @conference.opened?
      redirect_to("/#{@conference.abbr}/ui/")
    end
    @current = Video.on_air(@conference)
    @tracks = @conference.tracks

    @talks = @conference.talks.eager_load(:talk_category, :talk_difficulty).all
    @talk_categories = @conference.talk_categories
    @talk_difficulties = @conference.talk_difficulties
    @booths = @conference.booths.published
  end

  def waiting
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

  def reload
    ActionCable.server.broadcast('waiting_channel', 'aaa');
    render(plain: 'OK')
  end

  def blank
    @msg = params.key?(:msg) ? params[:msg] : 'No content'
    render(layout: false)
  end
end
