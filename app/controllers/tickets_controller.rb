class TicketsController < ApplicationController
  include Secured

  before_action :set_conference
  before_action :set_current_profile, only: [:edit, :update, :destroy]
  skip_before_action :logged_in_using_omniauth?, only: [:new]
  skip_before_action :need_order?, only: [:order_ticket]
  before_action :is_admin?, :find_profile, only: [:destroy_id, :set_role]

end
