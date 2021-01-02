class Admin::LinksController < ApplicationController
  include Secured
  include LogoutHelper

  before_action :is_admin?, :set_conference

  def index
    @links = Link.where(conference_id: @conference.id)
  end

  def edit
    @conference_form = ConferenceForm.new(conference: @conference)
    @conference_form.load
  end

  private

  def is_admin?
    raise Forbidden unless admin?
  end

  def conference_params
    params.require(:conference).permit(:status)
  end
end
