class SendAttendeeAnnouncementBatchJob < ApplicationJob
  queue_as :fifo
  self.queue_adapter = :sqs unless Rails.env.test?

  BATCH_SIZE = ENV.fetch('ATTENDEE_ANNOUNCEMENT_BATCH_SIZE', 100).to_i
  BATCH_INTERVAL = ENV.fetch('ATTENDEE_ANNOUNCEMENT_BATCH_INTERVAL_SECONDS', 30).to_i

  def perform(attendee_announcement_id)
    announcement = AttendeeAnnouncement.find_by(id: attendee_announcement_id)
    return if announcement.nil?

    deliveries = announcement.announcement_deliveries.queued.limit(BATCH_SIZE)
    return finalize_if_done(announcement) if deliveries.blank?

    delivery_ids = deliveries.pluck(:id)
    AnnouncementDelivery.where(id: delivery_ids).update_all(status: 'processing', updated_at: Time.zone.now)

    delivery_ids.each do |delivery_id|
      delivery = AnnouncementDelivery.find_by(id: delivery_id)
      next if delivery.nil?

      begin
        message = ProfileMailer.inform_attendee_announcement(delivery).deliver_now
        delivery.update!(status: 'sent', sent_at: Time.zone.now, provider_message_id: message&.message_id)
      rescue StandardError => e
        delivery.update!(status: 'failed', last_error: e.message)
      end
    end

    announcement.refresh_delivery_counts!
    self.class.set(wait: BATCH_INTERVAL.seconds).perform_later(announcement.id)
  end

  private

  def finalize_if_done(announcement)
    announcement.update!(send_status: 'completed', send_completed_at: Time.zone.now)
    announcement.refresh_delivery_counts!
  end
end
