class Admin::ChatsController < ApplicationController
  include Secured
  include LogoutHelper

  before_action :is_admin?, :set_conference

  def chat
  end

  private

  def is_admin?
    raise Forbidden unless admin?
  end
end
