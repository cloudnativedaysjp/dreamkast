class SpeakerInvitationsController < ApplicationController
  include SecuredSpeaker
  before_action :set_speaker
  def new
    @speaker_invitation = SpeakerInvitation.new
    @talk = Talk.find(params[:talk_id])
    if @speaker.talks.find(@talk.id).nil?
      render_404
    end
  end

  def create
    ActiveRecord::Base.transaction do
      @conference = Conference.find_by(abbr: params[:event])
      @invite = SpeakerInvitation.new(speaker_invitation_params)
      @invite.conference_id = @conference.id
      @invite.token = SecureRandom.hex(50)
      @invite.expires_at = 1.days.from_now  # 有効期限を1日後に設定
      if @invite.save
        SpeakerInvitationMailer.invite(@conference, @speaker, @invite.talk, @invite).deliver_now
        flash[:notice] = 'Invitation sent!'
        redirect_to("/#{@conference.abbr}/speaker_dashboard")
      else
        flash[:alert] = "#{@invite.email} への招待メール送信に失敗しました: #{@invite.errors.full_messages.join(', ')}"
        redirect_to(new_speaker_invitation_path(event: @conference.abbr, talk_id: @invite.talk_id))
      end
    end
  end

  private

  def speaker_invitation_params
    params.require(:speaker_invitation).permit(:email, :talk_id)
  end
end
