class ApplicationMailer < ActionMailer::Base
  default from: -> { default_from_address }
  layout 'mailer'
  self.delivery_job = MailDeliveryJob

  private

  def default_from_address
    conference_name = @conference&.name || 'CloudNative Days'
    "#{conference_name} 実行委員会 <noreply@mail.cloudnativedays.jp>"
  end
end
