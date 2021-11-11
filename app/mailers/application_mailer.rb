class ApplicationMailer < ActionMailer::Base
  default from: "CloudNative Days \u5B9F\u884C\u59D4\u54E1\u4F1A <noreply@mail.cloudnativedays.jp>"
  layout "mailer"
  self.delivery_job = MailDeliveryJob
end
