class AnnouncementDelivery < ApplicationRecord
  enum :status, { queued: 'queued', sent: 'sent', failed: 'failed' }

  belongs_to :announcement
  belongs_to :profile, optional: true
end
