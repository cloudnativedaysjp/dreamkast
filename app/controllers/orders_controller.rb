class OrdersController < ApplicationController
  include Secured

  before_action :set_conference, :set_profile
  skip_before_action :need_order?, only: [:create, :new]

  def new
    unless @profile.instance_of?(Profile) && @profile.orders.includes([:cancel_order]).all? { |order| order.cancel_order.present? }
      redirect_to("/#{event_name}/dashboard")
    end

    @order = Order.new
    @tickets = @conference.tickets
  end

  def create
    @order = Order.new(profile_id: @profile.id)
    @order.orders_tickets.build(ticket_id: order_params[:ticket_ids])

    if @order.save
      if @profile.public_profile.present?
        redirect_to("/#{event_name}/public_profiles/#{@profile.public_profile.id}/edit")
      else
        redirect_to("/#{event_name}/public_profiles/new")
      end
    else
      respond_to do |format|
        format.html { render(:new) }
        format.json { render(json: @order.errors, status: :unprocessable_entity) }
      end
    end
  end

  def order_params
    params.require(:order).permit(
      :ticket_ids
    )
  end
end
