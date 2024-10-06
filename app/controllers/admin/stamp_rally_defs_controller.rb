class Admin::StampRallyDefsController < ApplicationController
  include SecuredAdmin

  # def show
  #
  # end

  def index
    @stamp_rally_defs = conference.stamp_rally_defs
  end

  def new
    @stamp_rally_def = StampRallyDef.new
    @sponsors = conference.sponsors
    @type_options = StampRallyDef::Type::KLASSES.map(&:name)
  end

  def create
    @stamp_rally_def = StampRallyDef.new(stamp_rally_def_params.merge(conference: conference))
    if @stamp_rally_def.save
      flash.now[:notice] = "スタンプラリー定義 #{@stamp_rally_def.id}を登録しました"
    else
      render(:new, status: :unprocessable_entity)
    end
  end
  def edit
    @stamp_rally_def = StampRallyDef.find(params[:id])
    @sponsors = conference.sponsors
    @type_options = StampRallyDef::Type::KLASSES.map(&:name)
  end

  def update
    @stamp_rally_def = StampRallyDef.find(params[:id])
    if @stamp_rally_def.update(stamp_rally_def_params)
      flash.now[:notice] = "スタンプラリー定義 #{@stamp_rally_def.id}を更新しました"
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    @stamp_rally_def = StampRallyDef.find(params[:id])
    @stamp_rally_def.destroy
    flash.now[:notice] = 'スタンプラリー定義を削除しました'
  end

  def qr

  end

  private

  def stamp_rally_def_params
    params.require(:stamp_rally_def).permit(:sponsor_id, :type)
  end
end
