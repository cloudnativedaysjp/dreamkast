class ApplicationMailer < ActionMailer::Base
  default from: "CloudNative Days 実行委員会 <noreply@mail.cloudnativedays.jp>"
  layout "mailer"
  self.delivery_job = MailDeliveryJob
end
