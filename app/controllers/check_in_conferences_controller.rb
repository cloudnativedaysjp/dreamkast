class CheckInConferencesController < ApplicationController
  include Secured

  skip_before_action :redirect_to_registration
  skip_before_action :logged_in_using_omniauth?

  def new
    if logged_in? && @profile.present?
      check_in = CheckInConference.new(
        conference_id: @conference.id,
        profile_id: @profile.id,
        check_in_timestamp: Time.current
      )
      check_in.save
    end

    if logged_in? && @profile.nil?
      flash[:alert] = 'チェックインするためには参加登録が必要です。登録後、再度スキャンしてチェックインしてください。'
      redirect_to("/#{params[:event]}/registration")
      nil
    end
  end

  def check_in_conferences_params
    params.require(:check_in_conference).permit(
      :conference_id,
      :profile_id,
      :check_in_timestamp,
      :scanner_profile_id
    )
  end
end
