class EventController < ApplicationController
  include Secured
  include ActionView::Helpers::UrlHelper

  before_action :set_current_user, :set_profile, :set_speaker

  def show
    @conference = Conference.includes(sponsor_types: {sponsors: :sponsor_attachment_logo_image}).order("sponsor_types.order ASC").find_by(abbr: event_name)
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

  def sponsor_logo_class(sponsor_type)
    case sponsor_type.name
    when "Diamond", "Special Collaboration"
      "col-12 col-md-4 my-3 m-md-3"
    when "Platinum"
      "col-12 col-md-3 my-3 m-md-3"
    when "Gold", "Booth", "Mini Session", "CM", "Tool", "Logo"
      "col-12 col-md-2 my-3 m-md-3"
    else
      "col-12 col-md-3 my-3 m-md-3"
    end
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
