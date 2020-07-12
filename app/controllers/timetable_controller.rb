class TimetableController < ApplicationController
  include Secured
  before_action :set_profile
  
  def index
    # date = params[:date]

    @conference = Conference.find_by(abbr: event_name)
    # if date
    #   @conference_day = @conference.conference_days.find_by!(date: Time.parse(date))
    # else
    #   @conference_day = @conference.conference_days.sort {|a, b| a.date <=> b.date }.first
    # end
    # @talks = Talk.where(date: @conference_day.date)
  end

  private

  def set_profile
    @profile = Profile.find_by(email: @current_user[:info][:email])
  end
end
