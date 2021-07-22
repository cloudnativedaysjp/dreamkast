class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
  self.delivery_job = MailDeliveryJob
end
