class EventController < ApplicationController
  include Secured
  include SponsorHelper
  include ActionView::Helpers::UrlHelper

  before_action :set_current_user, :set_profile, :set_speaker

  def show
    @conference = Conference
                  .includes(sponsor_types: [{sponsors: :sponsor_attachment_logo_image}, :sponsors_sponsor_types])
                  .order("sponsor_types.order ASC")
                  .find_by(abbr: event_name)
    @talks = @conference.talks.accepted.includes(:talks_speakers, :speakers)

    render event_view
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
    @speaker.present? ? 'スピーカーダッシュボード' : 'スピーカーとしてエントリー'
  end
end
