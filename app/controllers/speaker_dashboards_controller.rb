class SpeakerDashboardsController < ApplicationController
  include SecuredSpeaker
  before_action :logged_in_using_omniauth?, :set_speaker

  def show
    @speaker_announcements = @conference.speaker_announcements.find_by_speaker(@speaker.id) unless @speaker.nil?
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
      '提出されたビデオファイルの確認中です。'
    elsif video_registration.confirmed?
      '提出されたビデオファイルの確認が完了しました。'
    end
  end

  def proposal_status(proposal)
    return 'エントリー済み' unless @conference.cfp_result_visible

    case proposal.status
    when 'registered'
      'エントリー済み'
    when 'accepted'
      '採択'
    when 'rejected'
      '不採択'
    end
  end
end
