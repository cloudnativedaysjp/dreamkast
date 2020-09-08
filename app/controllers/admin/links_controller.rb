class Admin::LinksController < ApplicationController
  include Secured
  include LogoutHelper

  before_action :is_admin?

  def index
    @conference = Conference.find_by(abbr: 'cndt2020')
    @links = Link.where(conference_id: @conference.id)
  end

  def edit
    @conference = Conference.find_by(abbr: 'cndt2020')
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
