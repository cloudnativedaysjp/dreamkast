# == Schema Information
#
# Table name: conferences
#
#  id                         :bigint           not null, primary key
#  abbr                       :string(255)
#  about                      :text(65535)
#  attendee_entry             :integer
#  brief                      :string(255)
#  cfp_result_visible         :boolean          default(FALSE)
#  coc                        :text(65535)
#  committee_name             :string(255)      default("CloudNative Days Committee"), not null
#  conference_status          :string(255)      default(NULL)
#  copyright                  :string(255)
#  name                       :string(255)
#  privacy_policy             :text(65535)
#  privacy_policy_for_speaker :text(65535)
#  show_sponsors              :boolean          default(FALSE)
#  show_timetable             :integer
#  speaker_entry              :integer
#  status                     :integer          default("registered"), not null
#  theme                      :text(65535)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_conferences_on_status  (status)
#

class Conference < ApplicationRecord
  STATUS_REGISTERED = 'registered'.freeze
  STATUS_OPENED = 'opened'.freeze
  STATUS_CLOSED = 'closed'.freeze
  STATUS_ARCHIVED = 'archived'.freeze

  enum conference_status: {
    registered: STATUS_REGISTERED,
    opened: STATUS_OPENED,
    closed: STATUS_CLOSED,
    archived: STATUS_ARCHIVED
  }
  enum speaker_entry: { speaker_entry_disabled: 0, speaker_entry_enabled: 1 }
  enum attendee_entry: { attendee_entry_disabled: 0, attendee_entry_enabled: 1 }
  enum show_timetable: { show_timetable_disabled: 0, show_timetable_enabled: 1 }

  has_many :form_items
  has_many :conference_days
  has_many :proposals
  has_many :talks
  has_many :tracks
  has_many :sponsors
  has_many :sponsor_types
  has_many :booths
  has_many :links
  has_many :talk_times
  has_many :talk_categories
  has_many :talk_difficulties
  has_many :speakers
  has_many :announcements
  has_many :speaker_announcements
  has_many :proposal_item_configs
  has_many :proposal_items
  has_many :profiles
  has_many :stats_of_registrants
  has_many :admin_profiles
  has_many :live_stream_media_live
  has_many :media_package_harvest_jobs
  has_many :tickets
  has_many :rooms

  scope :upcoming, -> {
    merge(where(status: 0).or(where(status: 1)))
  }

  scope :previous, -> {
    merge(where(status: 2).or(where(status: 3))).order(id: :desc)
  }

  scope :unarchived, -> {
    merge(where(status: 0).or(where(status: 1)).or(where(status: 2)))
  }

  def remaining_date
    (conference_days.where(internal: false).order(:date).first.date - Date.today).floor
  end
end
