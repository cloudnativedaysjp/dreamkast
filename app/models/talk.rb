class Talk < ApplicationRecord
  belongs_to :talk_category, optional: true
  belongs_to :talk_difficulty, optional: true

  has_many :talks_speakers
  has_many :speakers, through: :talks_speakers

  def self.import(file)
    destroy_all
    CSV.foreach(file.path, headers: true) do |row|
      talk = new
      talk.attributes = row.to_hash.slice(*updatable_attributes)
      talk.save
    end
  end

  def self.updatable_attributes
    ["id","title","abstract","track","talk_category_id","talk_difficulty_id","start_time","end_time","movie_url"]
  end
end
