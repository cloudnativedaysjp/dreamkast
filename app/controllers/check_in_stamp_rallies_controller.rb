class CheckInStampRalliesController < ApplicationController
  include Secured
  before_action :set_conference, :set_profile, :set_speaker

  def logged_in_using_omniauth?
    current_user
  end

  def index
    @check_in_stamp_rallies = @profile.check_in_stamp_rallies
  end

  def new
    @stamp_rally_defs = @conference.stamp_rally_defs
    @check_in_stamp_rally = CheckInStampRally.new
  end

  def create
    @check_in_stamp_rally = CheckInStampRally.new(check_in_stamp_rallies_params(params).merge(profile: @profile, check_in_timestamp: Time.zone.now))

    if @check_in_stamp_rally.save
      redirect_to(check_in_stamp_rallies_path)
    else
      respond_to do |format|
        format.html { render(:new, flash: { error: @check_in_stamp_rally.errors.messages }) }
      end
    end
  end


  def check_in_stamp_rallies_params(params)
    params.require(:check_in_stamp_rally)
          .permit(:stamp_rally_def_id)
  end
end
