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

class TalksSpeaker < ApplicationRecord
  belongs_to :talk, optional: true
  belongs_to :speaker, optional: true

  def self.updatable_attributes
    ['talk_id', 'speaker_id']
  end
end
