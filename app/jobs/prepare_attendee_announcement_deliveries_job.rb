class PrepareAttendeeAnnouncementDeliveriesJob < ApplicationJob
  queue_as :fifo
  self.queue_adapter = :sqs unless Rails.env.test?

  def perform(attendee_announcement_id)
    announcement = AttendeeAnnouncement.find_by(id: attendee_announcement_id)
    return if announcement.nil? || announcement.send_status != 'pending'

    announcement.update!(send_status: 'running', send_started_at: Time.zone.now)

    deliveries = []
    suppressed_count = 0

    announcement.target_profiles.find_each do |profile|
      email = profile.email
      if EmailSuppression.suppressed?(email)
        deliveries << build_delivery(announcement, profile, email, 'suppressed')
        suppressed_count += 1
        next
      end

      deliveries << build_delivery(announcement, profile, email, 'queued')
    end

    AnnouncementDelivery.insert_all!(deliveries) if deliveries.any?

    announcement.update!(suppressed_count:)
    announcement.refresh_delivery_counts!

    SendAttendeeAnnouncementBatchJob.perform_later(announcement.id)
  end

  private

  def build_delivery(announcement, profile, email, status)
    {
      attendee_announcement_id: announcement.id,
      profile_id: profile.id,
      email:,
      status:,
      created_at: Time.zone.now,
      updated_at: Time.zone.now
    }
  end
end
