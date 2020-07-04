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
    ["id","title","abstract","track","talk_category_id","talk_difficulty_id","date","start_time","end_time","movie_url"]
  end

  def day
    case self.date.day
    when 8 then
      return 1
    when 9 then
      return 2
    end
  end

  def track_name
    track_map = {"1" => "A", "2" => "B", "3" => "C", "4" => "D", "5" => "E", "6" => "F"}
    return track_map[self.track]
  end

  def slot_number
    slot_map = {"12" => "1", "13" => "1", "14" => "2", "15" => "3", "16" => "4", "17" => "5", "18" => "6", "19" => "7"}
     return slot_map[self.start_time.to_time.hour.to_s]
  end

  def talk_number
    return day.to_s + track_name + slot_number
  end

  def row_start
    ((self.start_time.in_time_zone('Asia/Tokyo') - Time.zone.parse("2000-01-01 12:00")) / 60 / 10).to_i + 7
  end

  def row_end
    ((self.end_time - self.start_time).to_i / 60 / 10) + row_start
  end
end
