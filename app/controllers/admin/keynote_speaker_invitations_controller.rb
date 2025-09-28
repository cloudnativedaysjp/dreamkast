class Admin::KeynoteSpeakerInvitationsController < ApplicationController
  include SecuredAdmin

  before_action :set_conference
  before_action :set_keynote_speaker_invitation, only: [:destroy, :resend]
  helper_method :turbo_stream_flash

  def index
    @keynote_speaker_invitations = @conference.keynote_speaker_invitations.includes(:speaker, :talk, :keynote_speaker_accept)
  end

  def new
    @keynote_speaker_invitation = @conference.keynote_speaker_invitations.build
  end

  def create
    @keynote_speaker_invitation = @conference.keynote_speaker_invitations.build(keynote_speaker_invitation_params)
    @keynote_speaker_invitation.created_by_id = current_user[:id]

    if @keynote_speaker_invitation.save
      KeynoteSpeakerInvitationMailer.invite(@keynote_speaker_invitation).deliver_now

      @keynote_speaker_invitations = @conference.keynote_speaker_invitations.includes(:speaker, :talk, :keynote_speaker_accept)
      flash.now[:notice] = '招待メールを送信しました。'
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def destroy
    if @keynote_speaker_invitation.accepted?
      flash.now[:alert] = '承諾済みの招待は削除できません。'
    else
      # 関連するSpeakerとTalkも削除
      ActiveRecord::Base.transaction do
        talk = @keynote_speaker_invitation.talk
        speaker = @keynote_speaker_invitation.speaker

        @keynote_speaker_invitation.destroy!
        talk&.destroy!
        speaker&.destroy!
      end

      flash.now[:notice] = '招待を削除しました。'
      @keynote_speaker_invitations = @conference.keynote_speaker_invitations.includes(:speaker, :talk, :keynote_speaker_accept)
    end
  end

  def resend
    if @keynote_speaker_invitation.accepted?
      flash.now[:alert] = '承諾済みの招待は再送信できません。'
    else
      # 有効期限を更新して再送信
      @keynote_speaker_invitation.update!(expires_at: 7.days.from_now)
      KeynoteSpeakerInvitationMailer.invite(@keynote_speaker_invitation).deliver_now

      flash.now[:notice] = '招待メールを再送信しました。'
      @keynote_speaker_invitations = @conference.keynote_speaker_invitations.includes(:speaker, :talk, :keynote_speaker_accept)
    end
  end

  private

  def set_conference
    @conference = Conference.find_by(abbr: params[:event])
  end

  def set_keynote_speaker_invitation
    @keynote_speaker_invitation = @conference.keynote_speaker_invitations.find(params[:id])
  end

  def keynote_speaker_invitation_params
    params.require(:keynote_speaker_invitation).permit(:email, :name)
  end

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
