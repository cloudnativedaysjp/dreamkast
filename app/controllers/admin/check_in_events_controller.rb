class Admin::CheckInEventsController < ApplicationController
  include SecuredAdmin

  def create
    @check_in = CheckInConference.new(check_in_events_params.merge(conference_id: conference.id, check_in_timestamp: DateTime.now))
    @profile = Profile.find(@check_in.profile_id)

    respond_to do |format|
      if @check_in.save
        flash.now[:notice] = "#{@profile.last_name} #{@profile.first_name} をチェックインしました"
      else
        flash.now[:alert] = "#{@profile.last_name} #{@profile.first_name} のチェックインに失敗しました"
      end
      format.turbo_stream
    end
  end

  def destroy_all
    @check_ins = CheckInConference.where(profile_id: check_in_events_params[:profile_id], conference_id: conference.id)
    @profile = Profile.find(check_in_events_params[:profile_id])

    respond_to do |format|
      if @check_ins.map(&:destroy!)
        flash.now[:notice] = "#{@profile.last_name} #{@profile.first_name} のチェックインをキャンセルしました"
      else
        flash.now[:alert] = "#{@profile.last_name} #{@profile.first_name} のチェックインキャンセルに失敗しました"
      end
      format.turbo_stream
    end
  end

  def check_in_events_params
    params.require(:check_in_event).permit(:id, :profile_id, :conference_id, :check_in_timestamp)
  end
end
