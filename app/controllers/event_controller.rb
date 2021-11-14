class EventController < ApplicationController
  include Secured
  include SponsorHelper
  include ActionView::Helpers::UrlHelper

  before_action :set_current_user, :set_profile, :set_speaker

  def show
    @conference = Conference
                  .includes(sponsor_types: [{ sponsors: :sponsor_attachment_logo_image }, :sponsors_sponsor_types])
                  .order("sponsor_types.order ASC")
                  .find_by(abbr: event_name)
    if logged_in? and (@conference.registered? || @conference.opened?)
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

  helper_method :speaker_entry_button_name

  def speaker_entry_button_name
    @speaker.present? ? "\u30B9\u30D4\u30FC\u30AB\u30FC\u30C0\u30C3\u30B7\u30E5\u30DC\u30FC\u30C9" : "\u30B9\u30D4\u30FC\u30AB\u30FC\u3068\u3057\u3066\u30A8\u30F3\u30C8\u30EA\u30FC"
  end
end
