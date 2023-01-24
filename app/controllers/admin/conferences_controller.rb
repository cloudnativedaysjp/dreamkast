class Admin::ConferencesController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

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
    referrer_controller = Rails.application.routes.recognize_path(request.referrer)[:controller]

    respond_to do |format|
      if @conference_form.save
        if @conference.opened?
          path = "/#{@conference.abbr}/#{@conference.abbr == 'cndt2020' ? 'tracks' : 'ui/'}"
          ActionCable.server.broadcast('waiting_channel', { msg: 'redirect to tracks', redirectTo: path })
        end
        redirect_path = if referrer_controller == 'admin/proposals'
                          admin_proposals_path
                        else
                          admin_path
                        end
        format.html { redirect_to(redirect_path, notice: 'Conference was successfully updated.') }
      else
        format.html { render(:edit) }
      end
    end
  end

  private

  def conference_params
    params.require(:conference).permit(:conference_status,
                                       :cfp_result_visible,
                                       :speaker_entry,
                                       :attendee_entry,
                                       :show_timetable,
                                       :show_sponsors,
                                       :brief,
                                       :privacy_policy,
                                       :privacy_policy_for_speaker,
                                       links_attributes: [:id, :title, :url, :description, :_destroy],
                                       conference_days_attributes: [:id, :date])
  end
end
