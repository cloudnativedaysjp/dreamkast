class SendAnnouncementBatchJob < ApplicationJob
  BATCH_SIZE = (ENV['ANNOUNCEMENT_BATCH_SIZE'] || 10).to_i
  BATCH_INTERVAL = (ENV['ANNOUNCEMENT_BATCH_INTERVAL_SECONDS'] || 1).to_i
  RATE_LIMIT_RETRY_WAIT = (ENV['ANNOUNCEMENT_RATE_LIMIT_RETRY_WAIT_SECONDS'] || 30).to_i

  queue_as :fifo
  self.queue_adapter = :sqs unless Rails.env.test?

  def perform(announcement_id)
    announcement = Announcement.find(announcement_id)
    batch = announcement.announcement_deliveries.queued.limit(BATCH_SIZE)
    retry_later = false

    Rails.logger.info("[SendAnnouncementBatchJob] announcement=#{announcement_id} batch_size=#{batch.count}")

    batch.each do |delivery|
      result = AnnouncementMailer.notify(announcement, delivery).deliver_now
      delivery.update!(status: :sent, provider_message_id: result.message_id)
    rescue StandardError => e
      if rate_limited_error?(e)
        Rails.logger.warn(
          "[SendAnnouncementBatchJob] rate limited announcement=#{announcement_id} " \
          "delivery=#{delivery.id} #{e.class}: #{e.message}"
        )
        retry_later = true
        break
      end

      Rails.logger.warn("[SendAnnouncementBatchJob] delivery=#{delivery.id} failed: #{e.class}: #{e.message}")
      delivery.update!(status: :failed, last_error: e.message)
    end

    refresh_counts!(announcement)

    if retry_later
      SendAnnouncementBatchJob.set(wait: RATE_LIMIT_RETRY_WAIT.seconds).perform_later(announcement_id)
      return
    end

    if announcement.announcement_deliveries.queued.exists?
      SendAnnouncementBatchJob.set(wait: BATCH_INTERVAL.seconds).perform_later(announcement_id)
    else
      announcement.update!(send_status: :completed)
    end
  end

  private

  def refresh_counts!(announcement)
    announcement.update!(
      sent_count: announcement.announcement_deliveries.sent.count,
      failed_count: announcement.announcement_deliveries.failed.count
    )
  end

  def rate_limited_error?(error)
    return true if defined?(Aws::SESV2::Errors::TooManyRequestsException) && error.is_a?(Aws::SESV2::Errors::TooManyRequestsException)
    return true if defined?(Aws::SESV2::Errors::LimitExceededException) && error.is_a?(Aws::SESV2::Errors::LimitExceededException)

    message = "#{error.class}: #{error.message}"
    message.include?('TooManyRequestsException') || message.include?('LimitExceededException')
  end
end
