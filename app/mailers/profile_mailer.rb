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

  def inform_attendee_announcement(conference, profile)
    @conference = conference
    @profile = profile

    mail(to: @profile.email, subject: "#{@conference.abbr}運営からのお知らせ")
  end
end
