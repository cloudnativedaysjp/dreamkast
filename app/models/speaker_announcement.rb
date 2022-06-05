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
#  receiver      :integer          default("0"), not null
#
# Indexes
#
#  index_speaker_announcements_on_conference_id  (conference_id)
#

class SpeakerAnnouncement < ApplicationRecord
  enum receiver: { person: 0, all_speaker: 1, only_accepted: 2, only_rejected: 3 }
  JA_RECEIVER = { person: '個人', all_speaker: '全員', only_accepted: 'CFP採択者', only_rejected: 'CFP非採択者' }.freeze

  belongs_to :conference
  has_many :speaker_announcement_middles, dependent: :destroy
  has_many :speakers, through: :speaker_announcement_middles

  validates :publish_time, presence: true
  validates :body, presence: true

  scope :published, lambda {
    where(publish: true)
  }

  scope :find_by_speaker, lambda { |speaker_id|
    if Speaker.find(speaker_id).has_accepted_proposal?
      joins(:speaker_announcement_middles).where(speaker_announcement_middles: { speaker_id: speaker_id }, publish: true)
    else
      joins(:speaker_announcement_middles).where(speaker_announcement_middles: { speaker_id: speaker_id }, publish: true).exclude_announcements_for_only_accepted
    end
  }

  scope :exclude_announcements_for_only_accepted, lambda {
    where(receiver: [:person, :all_speaker])
  }

  def speaker_names
    return speakers.map(&:name).join(',') if person?
    JA_RECEIVER[receiver.to_sym]
  end
end
