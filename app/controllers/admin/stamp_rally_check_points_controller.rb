class Admin::StampRallyCheckPointsController < ApplicationController
  include SecuredAdmin

  def reorder
    @stamp_rally_check_point = StampRallyCheckPoint.find(params[:id])
    @stamp_rally_check_point.insert_at(params[:position].to_i)
    head(:ok)
  end

  def index
    @stamp_rally_check_points = conference.stamp_rally_check_points.order(:position)
    @stamp_rally_configure = conference.stamp_rally_configure || StampRallyConfigure.new
  end

  def new
    @stamp_rally_check_point = StampRallyCheckPoint.new
    @sponsors = conference.sponsors
    @type_options = StampRallyCheckPoint::Type::KLASSES.map(&:name)
  end

  def create
    @stamp_rally_check_point = StampRallyCheckPoint.new(stamp_rally_check_point_params.merge(conference:))
    @sponsors = conference.sponsors
    @type_options = StampRallyCheckPoint::Type::KLASSES.map(&:name)
    if @stamp_rally_check_point.save
      flash.now[:notice] = "スタンプラリーチェックポイント #{@stamp_rally_check_point.id} を登録しました"
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def edit
    @stamp_rally_check_point = StampRallyCheckPoint.find(params[:id])
    @sponsors = conference.sponsors
    @type_options = StampRallyCheckPoint::Type::KLASSES.map(&:name)
  end

  def update
    @stamp_rally_check_point = StampRallyCheckPoint.find(params[:id])
    @sponsors = conference.sponsors
    @type_options = StampRallyCheckPoint::Type::KLASSES.map(&:name)
    if @stamp_rally_check_point.update(stamp_rally_check_point_params)
      flash.now.notice = "スタンプラリーチェックポイント #{@stamp_rally_check_point.id} を更新しました"
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    @stamp_rally_check_point = StampRallyCheckPoint.find(params[:id])
    if @stamp_rally_check_point.destroy
      flash.now.notice = "スタンプラリーチェックポイント #{@stamp_rally_check_point.id} を削除しました"
    else
      flash.now.alert = "スタンプラリーチェックポイント #{@stamp_rally_check_point.id} の削除に失敗しました"
    end
  end

  helper_method :turbo_stream_flash

  private

  def stamp_rally_check_point_params
    params.require(:stamp_rally_check_point).permit(:sponsor_id, :type, :name, :description)
  end

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
