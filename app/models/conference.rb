# == Schema Information
#
# Table name: conferences
#
#  id                         :bigint           not null, primary key
#  abbr                       :string(255)
#  about                      :text(16777215)
#  attendee_entry             :integer          default("attendee_entry_disabled")
#  brief                      :string(255)
#  capacity                   :integer
#  cfp_result_visible         :boolean          default(FALSE)
#  coc                        :text(16777215)
#  committee_name             :string(255)      default("CloudNative Days Committee"), not null
#  conference_status          :string(255)      default("registered")
#  contact_url                :text(65535)
#  copyright                  :string(255)
#  name                       :string(255)
#  privacy_policy             :text(16777215)
#  privacy_policy_for_speaker :text(16777215)
#  rehearsal_mode             :boolean          default(FALSE), not null
#  show_sponsors              :boolean          default(FALSE)
#  show_timetable             :integer          default("show_timetable_disabled")
#  speaker_entry              :integer          default("speaker_entry_disabled")
#  sponsor_guideline_url      :text(65535)
#  theme                      :text(16777215)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_conferences_on_abbr                        (abbr)
#  index_conferences_on_abbr_and_conference_status  (abbr,conference_status)
#

class Conference < ApplicationRecord
  STATUS_REGISTERED = 'registered'.freeze
  STATUS_OPENED = 'opened'.freeze
  STATUS_CLOSED = 'closed'.freeze
  STATUS_ARCHIVED = 'archived'.freeze
  STATUS_MIGRATED = 'migrated'.freeze

  enum conference_status: {
    registered: STATUS_REGISTERED,
    opened: STATUS_OPENED,
    closed: STATUS_CLOSED,
    archived: STATUS_ARCHIVED,
    migrated: STATUS_MIGRATED
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
