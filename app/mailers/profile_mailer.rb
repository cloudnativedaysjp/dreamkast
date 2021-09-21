class ProfileMailer < ApplicationMailer
  default from: 'CloudNative Days 実行委員会 <noreply@mail.cloudnativedays.jp>'
  layout 'mailer'

  def registered(profile, conference)
    @profile = profile
    @conference = conference

    mail(
      to: @profile.email,
      subject: "#{@conference.name}への登録ありがとうございます"
    )
  end
end
