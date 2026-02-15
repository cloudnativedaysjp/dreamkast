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

  def inform_attendee_announcement(delivery)
    @delivery = delivery
    @profile = delivery.profile
    @conference = delivery.attendee_announcement.conference

    headers['X-Attendee-Announcement-Id'] = delivery.attendee_announcement_id.to_s
    headers['X-Announcement-Delivery-Id'] = delivery.id.to_s
    headers['X-Profile-Id'] = delivery.profile_id.to_s
    configuration_set = ENV['SES_CONFIGURATION_SET']
    headers['X-SES-CONFIGURATION-SET'] = configuration_set if configuration_set.present?

    mail(to: @profile.email, subject: "#{@conference.abbr}運営からのお知らせ")
  end
end
