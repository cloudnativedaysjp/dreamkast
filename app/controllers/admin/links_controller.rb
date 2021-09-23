class Admin::LinksController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @links = Link.where(conference_id: @conference.id)
  end

  def edit
    @conference_form = ConferenceForm.new(conference: @conference)
    @conference_form.load
  end

  private

  def conference_params
    params.require(:conference).permit(:status)
  end
end
