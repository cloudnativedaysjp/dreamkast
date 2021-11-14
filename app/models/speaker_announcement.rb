class SpeakerAnnouncement < ApplicationRecord
  belongs_to :conference
  belongs_to :speaker

  validates :speaker_name, presence: true
  validates :publish_time, presence: true
  validates :body, presence: true

  scope :published, lambda {
    where(publish: true)
  }
end
