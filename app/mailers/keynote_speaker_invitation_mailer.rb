class KeynoteSpeakerInvitationMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  default from: 'CloudNative Days 実行委員会 <noreply@mail.cloudnativedays.jp>'
  layout 'mailer'

  def invite(keynote_speaker_invitation)
    @invitation = keynote_speaker_invitation
    @conference = @invitation.conference
    @accept_url = keynote_speaker_accepts_invite_url(event: @conference.abbr, token: @invitation.token)

    mail(
      to: @invitation.email,
      subject: "[#{@conference.name}] キーノートスピーカーとしてのご招待"
    )
  end

  def accepted(keynote_speaker_invitation)
    @invitation = keynote_speaker_invitation
    @conference = @invitation.conference
    @speaker = @invitation.speaker
    @talk = @invitation.talk
    @dashboard_url = speaker_dashboard_url(event: @conference.abbr)

    mail(
      to: @invitation.email,
      subject: "[#{@conference.name}] キーノートスピーカー招待承諾のご確認"
    )
  end
end
