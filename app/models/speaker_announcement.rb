class SpeakerAnnouncement < ApplicationRecord
  belongs_to :conference
  has_many :speaker_announcement_middles, dependent: :destroy
  has_many :speakers, through: :speaker_announcement_middles

  validates :speaker_names, presence: true
  validates :publish_time, presence: true
  validates :body, presence: true

  scope :published, lambda {
    where(publish: true)
  }

  scope :find_by_speaker, lambda { |speaker_id|
    joins(:speaker_announcement_middles).where(speaker_announcement_middles: { speaker_id: speaker_id }, publish: true)
  }

  # TODO: 複数人アナウンス時にカンマセパレートを行う
  # 現時点では1ユーザー名しかないのでそのまま返す
  def format_speaker_names
    speaker_names
  end
end
