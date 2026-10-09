class SponsorDashboards::SponsorContactInvitesController < ApplicationController
  include SecuredSponsorDashboard

  def new
    @conference = current_conference
    @sponsor_contact_invite = SponsorContactInvite.new
    @sponsor = current_conference.sponsors.find(params[:sponsor_id])
  end

  def create
    ActiveRecord::Base.transaction do
      @sponsor = current_conference.sponsors.find(params[:sponsor_id])
      @conference = current_conference
      @sponsor_contact_invite = @sponsor.sponsor_contact_invites.new(sponsor_contact_invite_params)
      @sponsor_contact_invite.conference_id = @conference.id
      @sponsor_contact_invite.token = SecureRandom.hex(50)
      @sponsor_contact_invite.expires_at = 7.days.from_now # 有効期限を7日後に設定
      if @sponsor_contact_invite.save
        SponsorContactInviteMailer.invite(@conference, @sponsor_contact_invite).deliver_now
        flash.now[:notice] = '招待メールを送信しました'
      else
        flash.now[:alert] = "#{@sponsor_contact_invite.email} への招待メール送信に失敗しました"
        render(:new, status: :unprocessable_entity)
      end
    end
  end

  def destroy
    @sponsor = current_conference.sponsors.find(params[:sponsor_id])
    @sponsor_contact_invite = @sponsor.sponsor_contact_invites.find(params[:id])
    @previous_sponsor_contact_invites = @sponsor.sponsor_contact_invites.where(conference_id: @sponsor_contact_invite.conference_id, email: @sponsor_contact_invite.email)
    if @sponsor_contact_invite.destroy && @previous_sponsor_contact_invites.destroy_all
      flash.now[:notice] = '招待を削除しました'
    else
      flash.now[:alert] = '招待の削除に失敗しました'
      render(:new, status: :unprocessable_entity)
    end
  end

  helper_method :turbo_stream_flash

  private

  def sponsor_contact_invite_params
    params.require(:sponsor_contact_invite).permit(:email)
  end

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
