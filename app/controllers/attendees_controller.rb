class AttendeesController < ApplicationController
  include Secured

  before_action :set_profile

  def logged_in_using_omniauth?
    current_user
  end

  def index
    @public_profiles = current_conference
                       .profiles.includes([:public_profile])
                       .joins(:public_profile)
                       .where(public_profile: { is_public: true })
                       .map(&:public_profile)
  end
end
