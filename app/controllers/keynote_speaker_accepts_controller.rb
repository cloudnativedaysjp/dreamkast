class KeynoteSpeakerAcceptsController < ApplicationController
  include SecuredSpeaker
  before_action :set_speaker

  skip_before_action :logged_in_using_omniauth?, only: [:invite]

  def invite
    return redirect_to(new_keynote_speaker_accept_path(token: params[:token])) if from_auth0?(params)
    @conference = Conference.find_by(abbr: params[:event])
    @keynote_speaker_invitation = KeynoteSpeakerInvitation.find_by(token: params[:token])

    unless @keynote_speaker_invitation
      render_404
      return
    end

    if @keynote_speaker_invitation.expired?
      render('expired')
      return
    end

    if @keynote_speaker_invitation.accepted?
      redirect_to(speaker_dashboard_path(event: @conference.abbr), notice: 'この招待は既に承諾済みです。')
      nil
    end
  end

  def new
    @keynote_speaker_accept = KeynoteSpeakerAccept.new
    @conference = Conference.find_by(abbr: params[:event])

    @keynote_speaker_invitation = KeynoteSpeakerInvitation.find_by(token: params[:token])
    unless @keynote_speaker_invitation
      raise(ActiveRecord::RecordNotFound)
    end

    if @keynote_speaker_invitation.expired?
      render('expired')
      return
    end

    if @keynote_speaker_invitation.accepted?
      redirect_to(speaker_dashboard_path(event: @conference.abbr), notice: 'この招待は既に承諾済みです。')
      return
    end

    @talk = @keynote_speaker_invitation.talk
    user_id = current_user_model&.id
    @speaker = Speaker.find_by(conference: @conference, user_id:) ||
               Speaker.new(conference: @conference, email: current_user[:info][:email], user_id:)
  end

  def create
    @conference = Conference.find_by(abbr: params[:event])
    @keynote_speaker_invitation = KeynoteSpeakerInvitation.find(params[:speaker][:keynote_speaker_invitation_id])

    if @keynote_speaker_invitation.expired?
      render('expired')
      return
    end

    if @keynote_speaker_invitation.accepted?
      redirect_to(speaker_dashboard_path(event: @conference.abbr), alert: 'この招待は既に承諾済みです。')
      return
    end

    begin
      ActiveRecord::Base.transaction do
        speaker_param = keynote_speaker_accept_params.merge(conference: @conference, email: current_user[:info][:email])
        speaker_param.delete(:keynote_speaker_invitation_id)

        # 既存の招待に紐づく暫定スピーカーを優先して更新し、重複作成による User 一意制約違反を防ぐ
        user_id = current_user_model&.id
        @speaker = Speaker.find_by(conference: @conference, user_id:) ||
                   @keynote_speaker_invitation.speaker ||
                   Speaker.new(conference: @conference, email: current_user[:info][:email], user_id:)
        @speaker.update!(speaker_param)
        @speaker.save!

        # 承諾処理
        @keynote_speaker_invitation.accept!(current_user[:extra][:raw_info][:sub])

        # 承諾確認メール送信
        KeynoteSpeakerInvitationMailer.accepted(@keynote_speaker_invitation).deliver_now

        redirect_to(speaker_dashboard_path(event: @conference.abbr), notice: 'キーノートスピーカーとしての招待を承諾しました。スピーカー情報とセッション情報を編集してください。')
      end
    rescue ActiveRecord::RecordInvalid => e
      logger.error("Failed to accept keynote speaker invitation: #{e.message}")
      render(:new, alert: '承諾処理に失敗しました。もう一度お試しください。')
    end
  end

  def keynote_speaker_accept_params
    params.require(:speaker).permit(
      :keynote_speaker_invitation_id,
      :name,
      :name_mother_tongue,
      :sub,
      :email,
      :profile,
      :company,
      :job_title,
      :twitter_id,
      :github_id,
      :avatar,
      :conference_id,
      :additional_documents
    )
  end

  def from_auth0?(params)
    params[:state].present?
  end
end
