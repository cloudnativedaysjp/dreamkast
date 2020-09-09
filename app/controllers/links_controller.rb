class LinksController < ApplicationController
  def index
    @conference = Conference.includes(talks: [:track, :speakers, :conference_day]).find_by(abbr: event_name)
    @links = Link.where(conference_id: @conference.id)
  end
end
