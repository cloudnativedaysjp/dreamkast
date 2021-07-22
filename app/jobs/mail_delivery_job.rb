class MailDeliveryJob < ApplicationJob
  queue_as :mail
  self.queue_adapter = :amazon_sqs

  discard_on ActiveRecord::ActiveRecordError

  def perform(mailer, mail_method, delivery_method, *args)
    mailer.constantize.public_send(mail_method, *args).send(delivery_method)
  end
end
