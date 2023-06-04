# == Schema Information
#
# Table name: talks_speakers
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  speaker_id :integer
#  talk_id    :integer
#
# Indexes
#
#  index_talks_speakers_on_speaker_id  (speaker_id)
#

class TalksSpeaker < ApplicationRecord
  belongs_to :talk, optional: true
  belongs_to :speaker, optional: true

  def self.updatable_attributes
    ['talk_id', 'speaker_id']
  end
end
