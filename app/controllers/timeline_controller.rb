class TimelineController < ApplicationController
  def index
    date = params[:date]

    @conference = Conference.find_by(name: "CloudNative Days Tokyo 2020")
    if date
      @talks = Talk.where(date: Time.parse(date))
    else
      @talks = Talk.where(date: @conference.conference_days.sort {|a, b| a.date <=> b.date }.first.date)
    end
  end
end
