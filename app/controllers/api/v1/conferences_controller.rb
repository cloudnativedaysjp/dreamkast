class Api::V1::ConferencesController < ApplicationController
  def show
    @conference = Conference.find_by(abbr: params[:id])
    render(:show, formats: :json, type: :jbuilder)
  end
end
