class AttendeeAnnouncement < ApplicationRecord
  enum :receiver, { person: 0, all_attendee: 1, only_online: 2, only_offline: 3, early_bird: 4 }
  JA_RECEIVER = {
    person: '個人',
    all_attendee: '全員',
    only_online: 'オンライン参加者',
    only_offline: '現地参加者',
    early_bird: '先行申込者'
  }.freeze

  after_commit -> { inform('create') }, on: :create
  after_commit -> { inform('update') }, on: :update

  belongs_to :conference
  has_many :attendee_announcement_middles, dependent: :destroy
  has_many :profiles, through: :attendee_announcement_middles
  has_many :announcement_deliveries, dependent: :destroy

  validates :publish_time, presence: true
  validates :body, presence: true

  scope :published, lambda {
    where(publish: true)
  }

  scope :find_by_profile, lambda { |profile_id|
    joins(:attendee_announcement_middles).where(attendee_announcement_middles: { profile_id: }, publish: true)
  }

  def inform(context)
    return unless should_inform?(context)
    return unless send_status == 'pending'

    PrepareAttendeeAnnouncementDeliveriesJob.perform_later(id)
  rescue StandardError => e
    Rails.logger.warn("Failed to enqueue attendee announcement prepare job: #{e.class} #{e.message}")
  end

  def profile_names
    return profiles.map { |profile| "#{profile.last_name} #{profile.first_name}" }.join(',') if person?

    JA_RECEIVER[receiver.to_sym]
  end

  def should_inform?(context)
    case context
    when 'create'
      publish
    when 'update'
      publish && publish_changed?
    end
  end

  def target_profiles
    case receiver
    when 'person'
      profiles
    when 'all_attendee'
      conference.profiles
    when 'only_online'
      conference.profiles.online
    when 'only_offline'
      conference.profiles.offline
    when 'early_bird'
      conference.profiles.where('created_at < ?', conference.early_bird_cutoff_at)
    else
      conference.profiles.none
    end
  end

  def delivery_counts
    announcement_deliveries.group(:status).count
  end

  def refresh_delivery_counts!
    counts = delivery_counts
    update!(
      sent_count: counts['sent'].to_i,
      failed_count: counts['failed'].to_i,
      bounced_count: counts['bounced'].to_i,
      suppressed_count: counts['suppressed'].to_i
    )
  end
end
