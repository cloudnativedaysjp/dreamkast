class Admin::KeynoteSpeakerInvitationsController < ApplicationController
  include SecuredAdmin

  before_action :set_conference
  before_action :set_keynote_speaker_invitation, only: [:destroy, :resend]

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
      redirect_to(admin_keynote_speaker_invitations_path(event: @conference.abbr), notice: '招待メールを送信しました。')
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def destroy
    if @keynote_speaker_invitation.accepted?
      redirect_to(admin_keynote_speaker_invitations_path(event: @conference.abbr), alert: '承諾済みの招待は削除できません。')
    else
      # 関連するSpeakerとTalkも削除
      ActiveRecord::Base.transaction do
        talk = @keynote_speaker_invitation.talk
        speaker = @keynote_speaker_invitation.speaker

        @keynote_speaker_invitation.destroy!
        talk&.destroy!
        speaker&.destroy!
      end

      redirect_to(admin_keynote_speaker_invitations_path(event: @conference.abbr), notice: '招待を削除しました。')
    end
  end

  def resend
    if @keynote_speaker_invitation.accepted?
      redirect_to(admin_keynote_speaker_invitations_path(event: @conference.abbr), alert: '承諾済みの招待は再送信できません。')
    else
      # 有効期限を更新して再送信
      @keynote_speaker_invitation.update!(expires_at: 7.days.from_now)
      KeynoteSpeakerInvitationMailer.invite(@keynote_speaker_invitation).deliver_now
      redirect_to(admin_keynote_speaker_invitations_path(event: @conference.abbr), notice: '招待メールを再送信しました。')
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
end
