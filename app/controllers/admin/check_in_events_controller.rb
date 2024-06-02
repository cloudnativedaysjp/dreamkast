class Admin::CheckInEventsController < ApplicationController
  include SecuredAdmin

  def create
    @check_in = CheckInConference.new(check_in_events_params.merge(conference_id: conference.id, check_in_timestamp: DateTime.now))
    @profile = Profile.find(@check_in.profile_id)

    if @check_in.save
      redirect_back(fallback_location: "#{conference.abbr}/admin", allow_other_host: false)
    else
      redirect_back(fallback_location: "#{conference.abbr}/admin", allow_other_host: false)
    end
  end

  def destroy_all
    @check_ins = CheckInConference.where(profile_id: check_in_events_params[:profile_id], conference_id: conference.id)
    @profile = Profile.find(check_in_events_params[:profile_id])

    if @check_ins.map(&:destroy!)
      redirect_back(fallback_location: "#{conference.abbr}/admin")
    else
      redirect_back(fallback_location: "#{conference.abbr}/admin")
    end
  end

  def check_in_events_params
    params.require(:check_in_event).permit(:id, :profile_id, :conference_id, :check_in_timestamp)
  end
end
