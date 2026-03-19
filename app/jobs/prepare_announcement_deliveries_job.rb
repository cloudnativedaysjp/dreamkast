class PrepareAnnouncementDeliveriesJob < ApplicationJob
  queue_as :fifo
  self.queue_adapter = :sqs unless Rails.env.test?

  def perform(announcement_id)
    announcement = Announcement.find(announcement_id)
    profiles = announcement.target_profiles.includes(:user)

    Rails.logger.info("[PrepareAnnouncementDeliveriesJob] announcement=#{announcement_id} target_count=#{profiles.count}")

    ActiveRecord::Base.transaction do
      profiles.each do |profile|
        AnnouncementDelivery.find_or_create_by!(announcement:, profile_id: profile.id) do |d|
          d.email = profile.email
          d.status = :queued
        end
      end
      announcement.update!(send_status: :processing)
    end

    SendAnnouncementBatchJob.perform_later(announcement_id)
  end
end
