class TalksSpeaker < ApplicationRecord
  belongs_to :talk, optional: true
  belongs_to :speaker, optional: true

  def self.import(file)
    destroy_all
    CSV.foreach(file.path, headers: true) do |row|
      talks_speaker = new
      talks_speaker.attributes = row.to_hash.slice(*updatable_attributes)
      talks_speaker.save
    end
  end

  def self.updatable_attributes
    ["talk_id","speaker_id"]
  end
end
