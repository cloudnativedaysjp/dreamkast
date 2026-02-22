class AnnouncementMailer < ApplicationMailer
  def notify(announcement, delivery)
    @announcement = announcement
    mail(to: delivery.email, subject: "#{announcement.conference.name}からのお知らせ")
  end
end
