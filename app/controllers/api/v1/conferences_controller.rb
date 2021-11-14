class Api::V1::ConferencesController < ApplicationController
  def show
    @conference = Conference.find_by(abbr: params[:id])
    render("api/v1/conferences/show.json.jbuilder")
  end
end
