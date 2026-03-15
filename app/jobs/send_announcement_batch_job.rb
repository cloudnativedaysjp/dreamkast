class SendAnnouncementBatchJob < ApplicationJob
  BATCH_SIZE = (ENV['ANNOUNCEMENT_BATCH_SIZE'] || 10).to_i
  BATCH_INTERVAL = (ENV['ANNOUNCEMENT_BATCH_INTERVAL_SECONDS'] || 1).to_i

  queue_as :fifo
  self.queue_adapter = :sqs unless Rails.env.test?

  def perform(announcement_id)
    announcement = Announcement.find(announcement_id)
    batch = announcement.announcement_deliveries.queued.limit(BATCH_SIZE)

    Rails.logger.info("[SendAnnouncementBatchJob] announcement=#{announcement_id} batch_size=#{batch.count}")

    batch.each do |delivery|
      result = AnnouncementMailer.notify(announcement, delivery).deliver_now
      delivery.update!(status: :sent, provider_message_id: result.message_id)
    rescue StandardError => e
      Rails.logger.warn("[SendAnnouncementBatchJob] delivery=#{delivery.id} failed: #{e.class}: #{e.message}")
      delivery.update!(status: :failed, last_error: e.message)
    end

    announcement.update!(
      sent_count: announcement.announcement_deliveries.sent.count,
      failed_count: announcement.announcement_deliveries.failed.count
    )

    if announcement.announcement_deliveries.queued.exists?
      SendAnnouncementBatchJob.set(wait: BATCH_INTERVAL.seconds).perform_later(announcement_id)
    else
      announcement.update!(send_status: :completed)
    end
  end
end
