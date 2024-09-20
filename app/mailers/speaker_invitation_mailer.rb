class SpeakerInvitationMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  default from: 'CloudNative Days 実行委員会 <noreply@mail.cloudnativedays.jp>'
  layout 'mailer'

  def invite(conference, invited_by, talk, invitation)
    @conference = conference
    @invited_by = invited_by
    @talk = talk
    @invitation = invitation
    @new_accept_url = speaker_invitation_accepts_invite_url(event: @conference.abbr, token: @invitation.token, protocol:)
    mail(to: @invitation.email, subject: "#{@conference.name} 共同スピーカー招待")
  end

  private

  def protocol
    Rails.env.production? ? 'https' : 'http'
  end
end
