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
  enum status: { registered: 0, opened: 1, closed: 2, archived: 3 }
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
  has_many :proposal_item_configs
  has_many :profiles
  has_many :stats_of_registrants
  has_many :admin_profiles
  has_many :live_stream_media_live

  scope :upcoming, -> {
    merge(where(status: 0).or(where(status: 1)))
  }

  scope :previous, -> {
    merge(where(status: 2).or(where(status: 3))).order(id: :desc)
  }

  scope :unarchived, -> {
    merge(where(status: 0).or(where(status: 1)).or(where(status: 2)))
  }
end
