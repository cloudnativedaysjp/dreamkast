class Conference < ApplicationRecord
  # - registered
  #   - イベント開催前、もしくは2日間のイベントで1日目が終わって2日目が始まるまで
  #   - TODO: 1日目と2日目の間を表現するステータスを追加する
  # - opened
  #   - イベント開催中
  # - closed
  #   - イベント開催後。この期間はアーカイブを見るためにはログインが必要
  # - archived
  #   - イベント開催後、ログインしなくてもアーカイブを見ることができる
  # - migrated
  #   - アーカイブをwebsiteに以降した後
  STATUS_REGISTERED = 'registered'.freeze
  STATUS_OPENED = 'opened'.freeze
  STATUS_CLOSED = 'closed'.freeze
  STATUS_ARCHIVED = 'archived'.freeze
  STATUS_MIGRATED = 'migrated'.freeze

  enum :conference_status, {
    registered: STATUS_REGISTERED,
    opened: STATUS_OPENED,
    closed: STATUS_CLOSED,
    archived: STATUS_ARCHIVED,
    migrated: STATUS_MIGRATED
  }
  enum :speaker_entry, { speaker_entry_disabled: 0, speaker_entry_enabled: 1 }
  enum :attendee_entry, { attendee_entry_disabled: 0, attendee_entry_enabled: 1 }
  enum :show_timetable, { show_timetable_disabled: 0, show_timetable_enabled: 1 }

  has_many :form_items
  has_many :conference_days
  has_many :proposals
  has_many :talks
  has_many :tracks
  has_many :sponsors
  has_many :sponsor_types
  has_many :sponsor_contacts
  has_many :links
  has_many :talk_times
  has_many :talk_categories
  has_many :talk_difficulties
  has_many :streamings
  has_many :speakers
  has_many :announcements
  has_many :speaker_announcements
  has_many :proposal_item_configs
  has_many :proposal_items
  has_many :profiles
  has_many :stats_of_registrants
  has_many :admin_profiles
  has_many :media_package_harvest_jobs
  has_many :rooms
  has_many :check_in_conferences
  has_many :stamp_rally_check_point_booths
  has_many :stamp_rally_check_point_finishes
  has_many :stamp_rally_check_points
  has_many :stamp_rally_check_ins
  has_one :stamp_rally_configure
  has_many :videos, through: :talks

  scope :upcoming, -> {
    merge(where(conference_status: Conference::STATUS_REGISTERED).or(where(conference_status: Conference::STATUS_OPENED)))
  }

  scope :previous, -> {
    merge(where(conference_status: Conference::STATUS_CLOSED).or(where(conference_status: Conference::STATUS_ARCHIVED))).order(id: :desc)
  }

  scope :unarchived, -> {
    merge(where(conference_status: Conference::STATUS_REGISTERED).or(where(conference_status: Conference::STATUS_OPENED)).or(where(conference_status: Conference::STATUS_CLOSED)))
  }

  def reach_capacity?
    return false if capacity.nil?
    profiles.where(participation: 'offline').size >= capacity
  end

  def remaining_date
    (conference_days.where(internal: false).order(:date).first.date - Date.today).floor
  end
end
