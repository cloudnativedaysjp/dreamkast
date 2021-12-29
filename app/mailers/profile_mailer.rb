class ProfileMailer < ApplicationMailer
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
