class TimetableController < ApplicationController
  def index
    date = params[:date]

    @conference = Conference.find_by(name: "CloudNative Days Tokyo 2020")
    if date
      @conference_day = @conference.conference_days.find_by!(date: Time.parse(date))
    else
      @conference_day = @conference.conference_days.sort {|a, b| a.date <=> b.date }.first
    end
    @talks = Talk.where(date: @conference_day.date)
  end
end
