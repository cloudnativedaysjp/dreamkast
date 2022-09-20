class Api::V1::ConferencesController < ApplicationController
  def index
    @conferences = Conference.all
    render(:index, formats: :json, type: :jbuilder)
  end

  def show
    @conference = Conference.find_by(abbr: params[:id])
    render(:show, formats: :json, type: :jbuilder)
  end
end
