class PrepareAnnouncementDeliveriesJob < ApplicationJob
  queue_as :fifo
  self.queue_adapter = :sqs unless Rails.env.test?

  def perform(announcement_id)
    announcement = Announcement.find(announcement_id)
    announcement.target_profiles.each do |profile|
      AnnouncementDelivery.create!(
        announcement:,
        profile:,
        email: profile.email,
        status: :queued
      )
    end
    announcement.update!(send_status: :processing)
    SendAnnouncementBatchJob.perform_later(announcement_id)
  end
end
