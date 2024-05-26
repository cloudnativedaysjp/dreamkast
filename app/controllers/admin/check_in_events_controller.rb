class Admin::CheckInEventsController < ApplicationController
  include SecuredAdmin

  def create
    @check_in = CheckInConference.new(check_in_events_params.merge(conference_id: conference.id, check_in_timestamp: DateTime.now))
    @profile = Profile.find(@check_in.profile_id)
    if @check_in.save
      redirect_back(fallback_location: "#{conference.abbr}/admin", notice: "#{@profile.last_name} #{@profile.first_name} がチェックインしました")
    else
      redirect_back(fallback_location: "#{conference.abbr}/admin", notice: "#{@profile.last_name} #{@profile.first_name} のチェックインに失敗しました")
    end
  end

  def check_in_events_params
    params.require(:check_in_event).permit(:id, :profile_id, :conference_id, :check_in_timestamp)
  end
end
