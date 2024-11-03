class StampRallyCheckInsController < ApplicationController
  include Secured
  before_action :set_conference, :set_profile, :set_speaker

  def logged_in_using_omniauth?
    current_user
  end

  def index
    @stamp_rally_check_points = @conference.stamp_rally_check_points.where.not(type: StampRallyCheckPointFinish.name)
    @stamp_rally_check_point_finishes = @conference.stamp_rally_check_point_finishes
    @stamp_rally_check_ins = @profile.stamp_rally_check_ins
  end

  def new
    @stamp_rally_check_point = @conference.stamp_rally_check_points.find(params[:stamp_rally_check_point_id])
    @stamp_rally_check_in = StampRallyCheckIn.new
  end

  def create
    @stamp_rally_check_in = StampRallyCheckIn.new(stamp_rally_check_ins_params(params).merge(profile: @profile, check_in_timestamp: Time.zone.now))

    if @stamp_rally_check_in.save
      redirect_to(stamp_rally_check_ins_path)
    else
      respond_to do |format|
        format.html { render(:new, flash: { error: @stamp_rally_check_in.errors.messages }) }
      end
    end
  end

  def stamp_rally_check_ins_params(params)
    params.require(:stamp_rally_check_in)
          .permit(:stamp_rally_check_point_id)
  end
end
