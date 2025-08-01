class MailDeliveryJob < ApplicationJob
  queue_as :fifo
  self.queue_adapter = :sqs unless Rails.env.test?

  discard_on ActiveRecord::ActiveRecordError

  def perform(mailer, mail_method, delivery_method, args:)
    mailer.constantize.public_send(mail_method, *args).send(delivery_method)
  end
end
