class Video < ApplicationRecord
  belongs_to :talk
  
  def self.on_air
    current = Video.where(on_air: true)
    list = {}
    list['current'] = []
    current.each do |video|
      list['current'][video.talk.track_id - 1] = {
        video_id: video.video_id,
        site: video.site,
        slido_id: video.slido_id,
        id: video.talk.id,
        title: video.talk.title,
        start_time: video.talk.start_time.strftime("%H:%M"),
        end_time: video.talk.end_time.strftime("%H:%M"),
        abstract: video.talk.abstract,
        track_name: video.talk.track.name,
        speakers: video.talk.speakers.map{|speaker| speaker.name}.join("/")
      }
    end
    return list
  end
end
