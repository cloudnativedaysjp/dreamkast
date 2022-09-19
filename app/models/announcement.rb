# == Schema Information
#
# Table name: announcements
#
#  id            :bigint           not null, primary key
#  body          :text(65535)
#  publish       :boolean
#  publish_time  :datetime
#  conference_id :bigint           not null
#
# Indexes
#
#  index_announcements_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#

class Announcement < ApplicationRecord
  belongs_to :conference

  scope :published, -> {
    where(publish: true)
  }
end
