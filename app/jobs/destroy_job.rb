class DestroyJob < ApplicationJob
  queue_as :fifo
  self.queue_adapter = :amazon_sqs unless Rails.env.test?

  def perform(data)
    attacher = Shrine::Attacher.from_data(data)
    attacher.destroy
  end
end
