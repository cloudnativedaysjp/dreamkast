class SponsorDashboards::SponsorSpeakerInvitesController < ApplicationController
  include SecuredSponsor

  def new
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor_speaker_invite = SponsorSpeakerInvite.new
    @sponsor = Sponsor.find(params[:sponsor_id])
    @sponsor_talks = @sponsor.talks
  end

  def create
    ActiveRecord::Base.transaction do
      @sponsor = Sponsor.find(params[:sponsor_id])
      @conference = Conference.find_by(abbr: params[:event])
      @sponsor_speaker_invite = SponsorSpeakerInvite.new(sponsor_speaker_invite_params)
      @sponsor_speaker_invite.conference_id = @conference.id
      @sponsor_speaker_invite.token = SecureRandom.hex(50)
      @sponsor_speaker_invite.expires_at = 1.days.from_now  # 有効期限を1日後に設定
      if @sponsor_speaker_invite.save
        @sponsor_speakers = @sponsor.speakers
        @sponsor_speaker_invites = @sponsor.sponsor_speaker_invites
        SponsorSpeakerInviteMailer.invite(@conference, @sponsor_speaker_invite).deliver_now
        flash.now[:notice] = '招待メールを送信しました'
      else
        flash.now[:alert] = "#{@sponsor_speaker_invite.email} への招待メール送信に失敗しました"
        render(:new, status: :unprocessable_entity)
      end
    end
  end

  def destroy
    @sponsor = Sponsor.find(params[:sponsor_id])
    @sponsor_speaker_invite = SponsorSpeakerInvite.find(params[:id])
    @previous_sponsor_speaker_invites = SponsorSpeakerInvite.where(conference_id: @sponsor_speaker_invite.conference_id, email: @sponsor_speaker_invite.email)
    if @sponsor_speaker_invite.destroy && @previous_sponsor_speaker_invites.destroy_all
      @sponsor_speakers = @sponsor.speakers
      @sponsor_speaker_invites = @sponsor.sponsor_speaker_invites
      flash.now[:notice] = '招待を削除しました'
    else
      flash.now[:alert] = '招待の削除に失敗しました'
      render(:new, status: :unprocessable_entity)
    end
  end

  helper_method :turbo_stream_flash

  private

  def sponsor_speaker_invite_params
    params.require(:sponsor_speaker_invite).permit(:email, :sponsor_id)
  end

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
