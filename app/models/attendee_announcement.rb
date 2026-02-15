class AttendeeAnnouncement < ApplicationRecord
  enum :receiver, { person: 0, all_attendee: 1, only_online: 2, only_offline: 3, early_bird: 4 }
  JA_RECEIVER = {
    person: '個人',
    all_attendee: '全員',
    only_online: 'オンライン参加者',
    only_offline: '現地参加者',
    early_bird: '先行申込者'
  }.freeze

  after_create -> { inform('create') }
  before_update -> { inform('update') }

  belongs_to :conference
  has_many :attendee_announcement_middles, dependent: :destroy
  has_many :profiles, through: :attendee_announcement_middles

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

    profiles.each do |profile|
      ProfileMailer.inform_attendee_announcement(conference, profile).deliver_later
    rescue StandardError => e
      Rails.logger.warn("Failed to enqueue attendee announcement mail: #{e.class} #{e.message}")
    end
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
end
