class SpeakerDashboardsController < ApplicationController
  include SecuredSpeaker
  before_action :logged_in_using_omniauth?, :set_speaker

  def show
  end

  def logged_in_using_omniauth?
    if logged_in?
      @current_user = session[:userinfo]
    end
  end

  def set_speaker
    @conference ||= Conference.find_by(abbr: params[:event])
    if @current_user
      @speaker = Speaker.find_by(conference_id: @conference.id, email: @current_user[:info][:email])
    end
  end

  private

  helper_method :video_registration_url, :video_registration_status, :proposal_status

  def video_registration_url(talk)
    if talk.video_registration.present?
      "/#{params[:event]}/speaker_dashboard/video_registrations/#{talk.video_registration.id}/edit"
    else
      "/#{params[:event]}/speaker_dashboard/video_registrations/new?talk_id=#{talk.id}"
    end
  end

  def video_registration_status(video_registration)
    if video_registration.submitted?
      "\u63D0\u51FA\u3055\u308C\u305F\u30D3\u30C7\u30AA\u30D5\u30A1\u30A4\u30EB\u306E\u78BA\u8A8D\u4E2D\u3067\u3059\u3002"
    elsif video_registration.confirmed?
      "\u63D0\u51FA\u3055\u308C\u305F\u30D3\u30C7\u30AA\u30D5\u30A1\u30A4\u30EB\u306E\u78BA\u8A8D\u304C\u5B8C\u4E86\u3057\u307E\u3057\u305F\u3002"
    end
  end

  def proposal_status(proposal)
    return "\u30A8\u30F3\u30C8\u30EA\u30FC\u6E08\u307F" unless @conference.cfp_result_visible

    case proposal.status
    when "registered"
      "\u30A8\u30F3\u30C8\u30EA\u30FC\u6E08\u307F"
    when "accepted"
      "\u63A1\u629E"
    when "rejected"
      "\u4E0D\u63A1\u629E"
    end
  end
end
