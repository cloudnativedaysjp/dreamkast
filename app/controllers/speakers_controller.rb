class SpeakersController < ApplicationController
  include Secured

  before_action :set_speaker, only: [:show]
  before_action :set_profile

  def logged_in_using_omniauth?
    current_user
  end

  # GET /speakers
  # GET /speakers.json
  def index
    @speakers = Speaker.all
  end

  # GET /speakers/1
  # GET /speakers/1.json
  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_speaker
    @speaker = Speaker.find(params[:id])
  end
end
