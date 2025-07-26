# == Schema Information
#
# Table name: announcements
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  publish_time  :datetime
#  body          :text(65535)
#  publish       :boolean
#
# Indexes
#
#  index_announcements_on_conference_id  (conference_id)
#

class Announcement < ApplicationRecord
  belongs_to :conference

  scope :published, -> {
    where(publish: true)
  }
end
