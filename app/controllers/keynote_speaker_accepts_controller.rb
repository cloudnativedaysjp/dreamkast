class KeynoteSpeakerAcceptsController < ApplicationController
  include SecuredSpeaker

  skip_before_action :logged_in_using_omniauth?, only: [:show, :create]
  before_action :set_conference, :set_keynote_speaker_invitation_by_token

  def show
    if @keynote_speaker_invitation.expired?
      render('expired')
      return
    end

    # Auth0未ログインの場合はログインページへリダイレクト
    if !logged_in?
      session[:return_to] = request.url
      redirect_to("/#{@conference.abbr}/auth/auth0")
    elsif @keynote_speaker_invitation.accepted?
      redirect_to(speaker_dashboard_path(event: @conference.abbr), notice: 'この招待は既に承諾済みです。')
    end
  end

  def create
    # Auth0未ログインの場合はログインページへリダイレクト
    unless logged_in?
      session[:return_to] = request.url
      redirect_to("/#{@conference.abbr}/auth/auth0")
      return
    end

    if @keynote_speaker_invitation.expired?
      render('expired')
      return
    end

    if @keynote_speaker_invitation.accepted?
      redirect_to(speaker_dashboard_path(event: @conference.abbr), alert: 'この招待は既に承諾済みです。')
      return
    end

    begin
      # 承諾処理
      @keynote_speaker_invitation.accept!(current_user[:extra][:raw_info][:sub])

      # 承諾確認メール送信
      KeynoteSpeakerInvitationMailer.accepted(@keynote_speaker_invitation).deliver_now

      # speaker_dashboardへリダイレクト
      redirect_to(speaker_dashboard_path(event: @conference.abbr), notice: 'キーノートスピーカーとしての招待を承諾しました。スピーカー情報とセッション情報を編集してください。')
    rescue ActiveRecord::RecordInvalid => e
      logger.error("Failed to accept keynote speaker invitation: #{e.message}")
      redirect_to(keynote_speaker_accept_path(token: params[:token]), alert: '承諾処理に失敗しました。もう一度お試しください。')
    end
  end

  private

  def conference
    @conference ||= Conference.find_by(abbr: params[:eventAbbr] || params[:event])
  end

  def set_conference
    conference
  end

  def set_keynote_speaker_invitation_by_token
    @keynote_speaker_invitation = KeynoteSpeakerInvitation.find_by(token: params[:token])
    unless @keynote_speaker_invitation
      render_404
      nil
    end
  end
end
