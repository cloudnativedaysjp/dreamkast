class AttendeesController < ApplicationController
  include Secured
  before_action :set_profile, :set_speaker

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end

  def index
    conference = Conference.find_by(abbr: params[:event])
    @public_profiles = conference
                       .profiles
                       .joins(:public_profile)
                       .where(public_profile: { is_public: true })
                       .map { |profile| profile.public_profile }
  end
end
