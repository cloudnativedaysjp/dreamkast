class TalksSpeaker < ApplicationRecord
  belongs_to :talk, optional: true
  belongs_to :speaker, optional: true

  def self.updatable_attributes
    ['talk_id', 'speaker_id']
  end
end
