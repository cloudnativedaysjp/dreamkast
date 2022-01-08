# == Schema Information
#
# Table name: speaker_announcements
#
#  id            :bigint           not null, primary key
#  body          :text(65535)      not null
#  only_accepted :boolean          default(FALSE)
#  publish       :boolean          default(FALSE)
#  publish_time  :datetime         not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#
# Indexes
#
#  index_speaker_announcements_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
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
    joins(:speaker_announcement_middles).where(speaker_announcement_middles: { speaker_id: speaker_id }, publish: true).accepted_only(speaker_id)
  }

  scope :accepted_only, lambda { |speaker_id|
    return if Speaker.find(speaker_id).proposal_accepted?
    where(only_accepted: false)
  }

  def speaker_names
    return '全員' if to_all
    speakers.map(&:name).join(',')
  end
end
