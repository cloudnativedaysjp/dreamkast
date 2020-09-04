class Admin::ConferencesController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?

  def index
  end

  def show
    @conference = Conference.find(params[:id])
  end

  def edit
    @conference = Conference.find(params[:id])
  end

  def update
    @conference = Conference.find(params[:id])

    respond_to do |format|
      if @conference.update(conference_params)
        if @conference.opened?
          ActionCable.server.broadcast("waiting_channel","redirect to tracks");
        end
        format.html { redirect_to "/admin", notice: "Conference was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  private

  def is_admin?
    raise Forbidden unless admin?
  end

  def conference_params
    params.require(:conference).permit(:status)
  end
end
