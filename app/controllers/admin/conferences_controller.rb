class Admin::ConferencesController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?, :set_conference

  def index
  end

  def show
  end

  def edit
    @conference_form = ConferenceForm.new(conference: @conference)
    @conference_form.load
  end

  def update
    @conference_form = ConferenceForm.new(conference_params, conference: @conference)

    respond_to do |format|
      if @conference_form.save
        if @conference.opened?
          path = "/#{@conference.abbr}/#{@conference.abbr == 'cndt2020' ? 'tracks' : 'ui/'}"
          ActionCable.server.broadcast("waiting_channel",{msg: "redirect to tracks", redirectTo: path})
        end
        format.html { redirect_to admin_path, notice: "Conference was successfully updated." }
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
    params.require(:conference).permit(:status,
                                       :speaker_entry,
                                       :attendee_entry,
                                       :show_timetable,
                                       links_attributes: [:id, :title, :url, :description, :_destroy])
  end
end
