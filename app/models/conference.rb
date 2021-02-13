class Conference < ApplicationRecord
  enum status: { registered: 0, opened: 1, closed: 2 }
  enum speaker_entry: { speaker_entry_disabled: 0, speaker_entry_enabled: 1 }
  enum attendee_entry: { attendee_entry_disabled: 0, attendee_entry_enabled: 1 }
  enum show_timetable: { show_timetable_disabled: 0, show_timetable_enabled: 1 }

  has_many :form_items
  has_many :conference_days
  has_many :talks
  has_many :tracks
  has_many :sponsors
  has_many :sponsor_types
  has_many :booths
  has_many :links
  has_many :talk_times
  has_many :talk_categories
  has_many :speakers
  has_many :announcements
end
