class Admin::SponsorContactInvitesController < ApplicationController
  include SecuredAdmin

  def new
    @sponsor_contact_invite = SponsorContactInvite.new
    @sponsor = Sponsor.find(params[:sponsor_id])
  end

  private

  def sponsor_contact_invite_params
    params.require(:sponsor_contact_invite).permit(:email, :sponsor_id)
  end
end
