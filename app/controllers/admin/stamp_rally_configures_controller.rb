class Admin::StampRallyConfiguresController < ApplicationController
  include SecuredAdmin

  def create
    @stamp_rally_configure = StampRallyConfigure.new(stamp_rally_configure_params.merge(conference:))
    if @stamp_rally_configure.save
      flash.now[:notice] = 'スタンプラリー設定を更新しました'
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def update
    @stamp_rally_configure = StampRallyConfigure.find(params[:id])
    if @stamp_rally_configure.update(stamp_rally_configure_params)
      flash.now[:notice] = 'スタンプラリー設定を更新しました'
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  helper_method :turbo_stream_flash

  private

  def stamp_rally_configure_params
    params.require(:stamp_rally_configure).permit(:finish_threshold)
  end

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
