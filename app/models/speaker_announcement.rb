# == Schema Information
#
# Table name: speaker_announcements
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  publish_time  :datetime         not null
#  body          :text(65535)      not null
#  publish       :boolean          default("0")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_speaker_announcements_on_conference_id  (conference_id)
#

class SpeakerAnnouncement < ApplicationRecord
  belongs_to :conference
  has_many :speaker_announcement_middles, dependent: :destroy
  has_many :speakers, through: :speaker_announcement_middles

  validates :publish_time, presence: true
  validates :body, presence: true

  scope :published, lambda {
    where(publish: true)
  }

  scope :find_by_speaker, lambda { |speaker_id|
    joins(:speaker_announcement_middles).where(speaker_announcement_middles: { speaker_id: speaker_id }, publish: true)
  }

  def speaker_names
    return '全員' if speakers.blank?
    speakers.map(&:name).join(',')
  end
end
