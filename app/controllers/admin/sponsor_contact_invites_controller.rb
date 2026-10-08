class Admin::SponsorContactInvitesController < ApplicationController
  include SecuredAdmin

  def new
    @sponsor_contact_invite = SponsorContactInvite.new
    @sponsor = current_conference.sponsors.find(params[:sponsor_id])
  end

  def create
    @sponsor = current_conference.sponsors.find(sponsor_contact_invite_params[:sponsor_id])
    ActiveRecord::Base.transaction do
      @sponsor_contact_invite = SponsorContactInvite.new(sponsor_contact_invite_params)
      @sponsor_contact_invite.conference_id = @conference.id
      @sponsor_contact_invite.token = SecureRandom.hex(50)
      @sponsor_contact_invite.expires_at = 7.days.from_now # 有効期限を7日後に設定
      if @sponsor_contact_invite.save
        SponsorContactInviteMailer.invite(@conference, @sponsor_contact_invite).deliver_now
        flash.now[:notice] = '招待メールを送信しました'
      else
        flash[:alert] = "#{@sponsor_contact_invite.email} への招待メール送信に失敗しました"
        render(:new, status: :unprocessable_entity)
      end
    end
  end

  def destroy
    @sponsor_contact_invite = SponsorContactInvite.where(conference_id: current_conference.id).find(params[:id])
    @previous_sponsor_contact_invites = SponsorContactInvite.where(conference_id: @sponsor_contact_invite.conference_id, sponsor_id: @sponsor_contact_invite.sponsor_id, email: @sponsor_contact_invite.email)
    if @sponsor_contact_invite.destroy && @previous_sponsor_contact_invites.destroy_all
      flash.now[:notice] = '招待を削除しました'
    else
      flash[:alert] = '招待の削除に失敗しました'
      render(:new, status: :unprocessable_entity)
    end
  end

  def sponsor_contact_invite_params
    params.require(:sponsor_contact_invite).permit(:email, :sponsor_id)
  end

  helper_method :turbo_stream_flash

  private

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
