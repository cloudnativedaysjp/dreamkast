class Announcement < ApplicationRecord
  enum :receiver, { all_attendee: 0, only_online: 2, only_offline: 3, early_bird: 4 }
  JA_RECEIVER = {
    all_attendee: '全員',
    only_online: 'オンライン参加者',
    only_offline: '現地参加者',
    early_bird: '先行申込者'
  }.freeze

  belongs_to :conference

  validates :receiver, presence: true

  scope :published, -> {
    where(publish: true)
  }

  def profile_names
    JA_RECEIVER[receiver.to_sym]
  end

  def self.visible_to(profile)
    base = where(publish: true, conference_id: profile.conference_id)
    result = base.where(receiver: :all_attendee)

    result = if profile.online?
               result.or(base.where(receiver: :only_online))
             else
               result.or(base.where(receiver: :only_offline))
             end

    if profile.created_at < profile.conference.early_bird_cutoff_at
      result = result.or(base.where(receiver: :early_bird))
    end

    result
  end
end
