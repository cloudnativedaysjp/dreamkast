class Talk < ApplicationRecord
  belongs_to :talk_category
  belongs_to :talk_difficulty

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

  def row_start
    ((self.start_time.localtime - Time.parse("2000-01-01 10:00")) / 60 / 10).to_i + 7
  end

  def row_end
    ((self.end_time - self.start_time).to_i / 60 / 10) + row_start
  end
end
