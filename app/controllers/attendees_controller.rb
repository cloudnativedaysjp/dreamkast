class AttendeesController < ApplicationController
  include Secured

  EARLY_BIRD_CUTOFF = Time.zone.parse('2026-03-01')

  before_action :set_profile

  def logged_in_using_omniauth?
    current_user
  end

  def index
    conference = Conference.find_by(abbr: params[:event])
    @public_profiles = conference
                       .profiles.includes([:public_profile])
                       .joins(:public_profile)
                       .where(public_profile: { is_public: true })
                       .map(&:public_profile)
    @early_bird_cutoff = EARLY_BIRD_CUTOFF
  end
end
