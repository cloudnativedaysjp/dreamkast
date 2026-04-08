class SponsorDashboards::SponsorContactInvitesController < ApplicationController
  include SecuredSponsor

  def new
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor_contact_invite = SponsorContactInvite.new
    @sponsor = Sponsor.find(params[:sponsor_id])
  end

  def create
    ActiveRecord::Base.transaction do
      @sponsor = Sponsor.find(params[:sponsor_id])
      @conference = Conference.find_by(abbr: params[:event])
      @sponsor_contact_invite = SponsorContactInvite.new(sponsor_contact_invite_params)
      @sponsor_contact_invite.conference_id = @conference.id
      @sponsor_contact_invite.token = SecureRandom.hex(50)
      @sponsor_contact_invite.expires_at = 1.days.from_now # 有効期限を1日後に設定
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
    @sponsor = Sponsor.find(params[:sponsor_id])
    @sponsor_contact_invite = SponsorContactInvite.find(params[:id])
    @previous_sponsor_contact_invites = SponsorContactInvite.where(conference_id: @sponsor_contact_invite.conference_id, email: @sponsor_contact_invite.email)
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
    params.require(:sponsor_contact_invite).permit(:email, :sponsor_id)
  end

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
