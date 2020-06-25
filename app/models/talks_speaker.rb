class TalksSpeaker < ApplicationRecord
  belongs_to :talk, optional: true
  belongs_to :speaker, optional: true
end
