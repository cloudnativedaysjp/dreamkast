class EventController < ApplicationController
  include Secured
  include SponsorHelper
  include ActionView::Helpers::UrlHelper

  before_action :set_current_user, :set_profile, :set_speaker

  def show
    @conference = Conference
                  .includes(sponsor_types: [{ sponsors: :sponsor_attachment_logo_image }, :sponsors_sponsor_types])
                  .order('sponsor_types.order ASC')
                  .find_by(abbr: event_name)
    if !@conference.speaker_entry_enabled? and logged_in? and (@conference.registered? || @conference.opened?)
      redirect_to("/#{@conference.abbr}/dashboard")
    else
      @talks = @conference.talks.accepted.includes(:talks_speakers, :speakers)

      render(event_view)
    end
  end

  def set_current_user
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end

  def privacy
    @conference = Conference.find_by(abbr: params[:event])
  end

  def coc
    @conference = Conference.find_by(abbr: params[:event])
  end

  private

  def use_secured_before_action?
    false
  end

  helper_method :speaker_entry_button_name, :speaker_entry_button_path

  def speaker_entry_button_name
    @speaker.present? ? 'スピーカーダッシュボード' : 'スピーカーとしてエントリー'
  end

  def speaker_entry_button_path
    @speaker.present? ? speaker_dashboard_path : speakers_guidance_path
  end
end
