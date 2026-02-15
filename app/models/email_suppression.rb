class EmailSuppression < ApplicationRecord
  REASONS = %w[bounce complaint manual].freeze
  SOURCES = %w[ses].freeze
  STATUSES = %w[active cleared].freeze

  validates :email, presence: true
  validates :reason, inclusion: { in: REASONS }
  validates :source, inclusion: { in: SOURCES }
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: 'active') }

  def self.suppressed?(email)
    active.where(email:).exists?
  end
end
