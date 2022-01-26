# == Schema Information
#
# Table name: talks_speakers
#
#  id         :integer          not null, primary key
#  talk_id    :integer
#  speaker_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TalksSpeaker < ApplicationRecord
  belongs_to :talk, optional: true
  belongs_to :speaker, optional: true

  def self.updatable_attributes
    ['talk_id', 'speaker_id']
  end
end
