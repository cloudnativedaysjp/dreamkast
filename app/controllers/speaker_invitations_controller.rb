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
      @invitation = SpeakerInvitation.new(speaker_invitation_params)
      @invitation.conference_id = @conference.id
      @invitation.token = SecureRandom.hex(50)
      @invitation.expires_at = 1.days.from_now  # 有効期限を1日後に設定
      if @invitation.save
        SpeakerInvitationMailer.invite(@conference, @speaker, @invitation.talk, @invitation).deliver_now
        flash.now[:notice] = 'Invitation sent!'
      else
        flash.now[:alert] = 'Failed to send invitation.'
      end
      redirect_to("/#{@conference.abbr}/speaker_dashboard")
    end
  end

  private

  def speaker_invitation_params
    params.require(:speaker_invitation).permit(:email, :talk_id)
  end
end
