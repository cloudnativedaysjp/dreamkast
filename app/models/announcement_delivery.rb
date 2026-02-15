class AnnouncementDelivery < ApplicationRecord
  belongs_to :attendee_announcement
  belongs_to :profile

  STATUSES = %w[queued processing sent failed bounced complaint suppressed].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :email, presence: true

  scope :queued, -> { where(status: 'queued') }
  scope :processing, -> { where(status: 'processing') }
  scope :sent, -> { where(status: 'sent') }
  scope :failed, -> { where(status: 'failed') }
  scope :bounced, -> { where(status: 'bounced') }
  scope :complaint, -> { where(status: 'complaint') }
  scope :suppressed, -> { where(status: 'suppressed') }
end
