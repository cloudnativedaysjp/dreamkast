class SponsorContactInviteMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  default from: 'CloudNative Days 実行委員会 <noreply@mail.cloudnativedays.jp>'
  layout 'mailer'

  def invite(conference, invitation)
    @conference = conference
    @invitation = invitation
    @new_accept_url = sponsor_contact_invite_accepts_invite_url(event: @conference.abbr, token: @invitation.token, protocol:)
    mail(to: @invitation.email, subject: "#{@conference.name} スポンサー担当者招待")
  end

  private

  def protocol
    Rails.env.production? ? 'https' : 'http'
  end
end
