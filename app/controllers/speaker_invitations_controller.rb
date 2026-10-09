class SpeakerInvitationsController < ApplicationController
  include SecuredSpeaker
  before_action :set_speaker
  def new
    @speaker_invitation = SpeakerInvitation.new
    @talk = @speaker&.talks&.find_by(id: params[:talk_id])
    render_404 unless @talk
  end

  def create
    # 自分が登壇するセッション以外へ共同登壇者を招待させない。
    talk = @speaker&.talks&.find_by(id: speaker_invitation_params[:talk_id])
    return render_404 unless talk

    ActiveRecord::Base.transaction do
      @conference = current_conference
      @invitation = SpeakerInvitation.new(speaker_invitation_params.merge(talk_id: talk.id))
      @invitation.conference_id = @conference.id
      @invitation.token = SecureRandom.hex(50)
      @invitation.expires_at = 7.days.from_now # 有効期限を7日後に設定
      if @invitation.save
        SpeakerInvitationMailer.invite(@conference, @speaker, @invitation.talk, @invitation).deliver_now
        flash[:notice] = 'Invitation sent!'
        redirect_to("/#{@conference.abbr}/speaker_dashboard")
      else
        flash[:alert] = "#{@invitation.email} への招待メール送信に失敗しました: #{@invitation.errors.full_messages.join(', ')}"
        redirect_to(new_speaker_invitation_path(event: @conference.abbr, talk_id: @invitation.talk_id))
      end
    end
  end

  private

  def speaker_invitation_params
    params.require(:speaker_invitation).permit(:email, :talk_id)
  end
end
