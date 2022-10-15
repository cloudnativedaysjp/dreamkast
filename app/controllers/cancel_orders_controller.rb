class CancelOrdersController < ApplicationController
  include Secured

  before_action :set_conference, :set_profile
  skip_before_action :logged_in_using_omniauth?, only: [:new]
  skip_before_action :need_order?, only: [:create]

  def new
    @order = Order.find(params[:order_id])
    @cancel_order = CancelOrder.new(order_id: @order.id)
  end

  def create
    @cancel_order = CancelOrder.new(cancel_order_params)

    respond_to do |format|
      if @cancel_order.save
        RegisteredTalk.where(profile_id: @profile.id).delete_all
        format.html { redirect_to(new_order_path, notice: 'キャンセルされました。') }
        format.json { head(:no_content) }
      else
        format.html { render(:edit) }
        format.json { render(json: @announcement.errors, status: :unprocessable_entity) }
      end
    end
  end

  def cancel_order_params
    params.require(:cancel_order).permit(:order_id)
  end
end
