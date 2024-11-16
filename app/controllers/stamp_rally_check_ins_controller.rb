class StampRallyCheckInsController < ApplicationController
  include Secured
  before_action :set_conference, :set_profile, :set_speaker

  def index
    @stamp_rally_check_points = @conference.stamp_rally_check_points.where.not(type: StampRallyCheckPointFinish.name)
    @stamp_rally_check_point_finishes = @conference.stamp_rally_check_point_finishes
    @stamp_rally_check_ins = @profile.stamp_rally_check_ins
  end

  def new
    @stamp_rally_check_point = @conference.stamp_rally_check_points.find(params[:stamp_rally_check_point_id])
    if StampRallyCheckIn.find_by(stamp_rally_check_point_id: params[:stamp_rally_check_point_id], profile: @profile).present?
      redirect_to(stamp_rally_check_ins_path)
    else
      @stamp_rally_check_in = StampRallyCheckIn.new({ stamp_rally_check_point_id: params[:stamp_rally_check_point_id], profile: @profile, check_in_timestamp: Time.zone.now })

      if @stamp_rally_check_in.save
        redirect_to(stamp_rally_check_ins_path, flash: { notice: @stamp_rally_check_point.name.to_s })
      else
        respond_to do |format|
          format.html { render(:new, flash: { error: @stamp_rally_check_in.errors.messages }) }
        end
      end
    end
  end

  def stamp_rally_check_ins_params(params)
    params.require(:stamp_rally_check_in)
          .permit(:stamp_rally_check_point_id)
  end

  helper_method :stamp_rally_status

  def stamp_rally_status
    check_points = conference.stamp_rally_check_points.where.not(type: StampRallyCheckPointFinish.name)
    check_ins = check_ins(StampRallyCheckPointBooth) + check_ins(StampRallyCheckPoint)
    finish_check_in = check_ins(StampRallyCheckPointFinish)
    finish_threshold = if conference.stamp_rally_configure.present? && conference.stamp_rally_configure.finish_threshold >= 0
                         conference.stamp_rally_configure.finish_threshold
                       else
                         check_points.size
                       end

    if @profile.stamp_rally_check_ins.empty?
      :not
    elsif finish_threshold > check_ins.size
      :in_progress
    elsif check_ins.size >= finish_threshold && finish_check_in.empty?
      :pre_finished
    elsif check_ins.size >= finish_threshold && finish_check_in.present?
      :finished
    else
      :error
    end
  end

  def check_ins(klass)
    @profile.stamp_rally_check_ins.joins(:stamp_rally_check_point).where(stamp_rally_check_point: { type: klass.name })
  end
end
