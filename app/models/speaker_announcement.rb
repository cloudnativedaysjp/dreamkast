class SpeakerAnnouncement < ApplicationRecord
  belongs_to :conference
  has_many :speaker_announcement_middles, dependent: :destroy
  has_many :speakers, through: :speaker_announcement_middles
  accepts_nested_attributes_for :speaker_announcement_middles, allow_destroy: true

  validates :speaker_names, presence: true
  validates :publish_time, presence: true
  validates :body, presence: true

  scope :published, lambda {
    where(publish: true)
  }

  # TODO: 複数人アナウンス時にカンマセパレートを行う
  # 現時点では1ユーザー名しかないのでそのまま返す
  def format_speaker_names
    speaker_names
  end
end
