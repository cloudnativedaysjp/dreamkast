class SpeakerDashboardsController < ApplicationController
  include SecuredSpeaker
  before_action :logged_in_using_omniauth?, :set_speaker

  def show
    # @speaker = Speaker.find_by(id: params[:id])
    # render_404 unless @speaker
    # authorize @speaker

    @conference ||= Conference.find_by(abbr: params[:event])
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
end
