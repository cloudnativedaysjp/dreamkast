class Admin::StampRallyCheckPointsController < ApplicationController
  include SecuredAdmin

  def index
    @stamp_rally_check_points = conference.stamp_rally_check_points
  end

  def new
    @stamp_rally_check_point = StampRallyCheckPoint.new
    @sponsors = conference.sponsors
    @type_options = StampRallyCheckPoint::Type::KLASSES.map(&:name)
  end

  def create
    @stamp_rally_check_point = StampRallyCheckPoint.new(stamp_rally_check_point_params.merge(conference:))
    if @stamp_rally_check_point.save
      flash.now[:notice] = "スタンプラリー定義 #{@stamp_rally_check_point.id}を登録しました"
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
    if @stamp_rally_check_point.update(stamp_rally_check_point_params)
      flash.now[:notice] = "スタンプラリー定義 #{@stamp_rally_check_point.id}を更新しました"
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    @stamp_rally_check_point = StampRallyCheckPoint.find(params[:id])
    @stamp_rally_check_point.destroy
    flash.now[:notice] = 'スタンプラリー定義を削除しました'
  end

  private

  def stamp_rally_check_point_params
    params.require(:stamp_rally_check_point).permit(:sponsor_id, :type)
  end
end
