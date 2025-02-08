class SponsorContactInvitesController < ApplicationController
  include SecuredAdmin

  def create
    ActiveRecord::Base.transaction do
      @conference = Conference.find_by(abbr: params[:event])
      @invite = SponsorContactInvite.new(sponsor_contact_invite_params)
      @invite.conference_id = @conference.id
      @invite.token = SecureRandom.hex(50)
      @invite.expires_at = 1.days.from_now  # 有効期限を1日後に設定
      if @invite.save
        SponsorContactInviteMailer.invite(@conference, @invite).deliver_now
        flash[:notice] = 'Invitation sent!'
        redirect_to(admin_sponsor_path(id: @invite.sponsor_id))
      else
        flash[:alert] = "#{@invite.email} への招待メール送信に失敗しました: #{@invite.errors.full_messages.join(', ')}"
        redirect_to(new_sponsor_contact_invite_path(event: @conference.abbr, talk_id: @invite.talk_id))
      end
    end
  end

  private

  def sponsor_contact_invite_params
    params.require(:sponsor_contact_invite).permit(:email, :sponsor_id)
  end
end
