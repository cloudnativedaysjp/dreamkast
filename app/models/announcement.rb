class Announcement < ApplicationRecord
  enum :receiver, { all_attendee: 0, only_online: 1, only_offline: 2, early_bird: 3 }
  enum :send_status, { pending: 'pending', processing: 'processing', completed: 'completed' }
  JA_RECEIVER = {
    all_attendee: '全員',
    only_online: 'オンライン参加者',
    only_offline: '現地参加者',
    early_bird: '先行申込者'
  }.freeze

  belongs_to :conference
  has_many :announcement_deliveries, dependent: :destroy

  validates :receiver, presence: true

  after_save :schedule_delivery, if: :saved_change_to_publish?

  scope :published, -> {
    where(publish: true)
  }

  def profile_names
    JA_RECEIVER[receiver.to_sym]
  end

  def target_profiles
    base = conference.profiles
    case receiver
    when 'all_attendee' then base
    when 'only_online'  then base.online
    when 'only_offline' then base.offline
    when 'early_bird'   then base.where('profiles.created_at < ?', conference.early_bird_cutoff_at)
    else
      raise(ArgumentError, "Unknown receiver: #{receiver}")
    end
  end

  def self.visible_to(profile)
    return none unless profile.is_a?(Profile)

    conference = profile.conference
    return none unless conference.present?

    base = where(publish: true, conference_id: profile.conference_id)
    result = base.where(receiver: :all_attendee)

    result = if profile.online?
               result.or(base.where(receiver: :only_online))
             else
               result.or(base.where(receiver: :only_offline))
             end

    if conference.early_bird_cutoff_at && profile.created_at < conference.early_bird_cutoff_at
      result = result.or(base.where(receiver: :early_bird))
    end

    result
  end

  private

  def schedule_delivery
    PrepareAnnouncementDeliveriesJob.perform_later(id) if publish?
  end
end
