class Video < ApplicationRecord
  belongs_to :talk
  
  def self.on_air
    current = Video.where(on_air: true)
    list = {}
    list['current'] = []
    current.each do |video|
      list['current'][video.talk.track_id - 1] = {
        url: video.url,
        site: video.site,
        id: video.talk.id,
        title: video.talk.title,
        start_time: video.talk.start_time,
        end_time: video.talk.end_time,
        abstract: video.talk.abstract,
        track_name: video.talk.track.name,
      }
    end
    return list
  end
end
