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
    @stamp_rally_check_in = StampRallyCheckIn.new
    @stamp_rally_check_ins = @profile.stamp_rally_check_ins
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

  helper_method :stamp_rally_status

  def stamp_rally_status
    check_points = conference.stamp_rally_check_points.where.not(type: StampRallyCheckPointFinish.name)
    check_ins = check_ins(StampRallyCheckPointBooth) + check_ins(StampRallyCheckPoint)
    finish_check_in = check_ins(StampRallyCheckPointFinish)
    finish_threshold = if conference.stamp_rally_configure.present? && conference.stamp_rally_configure.finish_threshold >= 0
                         conference.stamp_rally_configure.finish_threshold
                       elsif conference.stamp_rally_configure.present? && conference.stamp_rally_configure.finish_threshold == -1
                         check_points.size
                       else
                         check_points.size
                       end

    if @profile.stamp_rally_check_ins.empty?
      :not
    elsif finish_threshold > check_ins.size
      :in_progress
    elsif check_ins.size >= finish_threshold && finish_check_in.empty?
      :pre_finished
    elsif check_ins.size == check_points.size && finish_check_in.present?
      :finished
    else
      :error
    end
  end

  def check_ins(klass)
    @profile.stamp_rally_check_ins.joins(:stamp_rally_check_point).where(stamp_rally_check_point: { type: klass.name })
  end
end
