module TalksHelper
  def self.update_talks(conference, videos)
    videos.each do |talk_id, value|
      talk = Talk.find(talk_id)
      if talk.video
        video = Talk.find(talk_id).video
      else
        video = Video.new
        video.talk_id = talk.id
      end
      video.video_id = value[:video_id]
      if value[:on_air]
        video.on_air = true
      else
        video.on_air = false
      end
      video.save
    end
    ActionCable.server.broadcast(
      'track_channel', Video.on_air(conference)
    )
    ActionCable.server.broadcast(
      "on_air_#{conference.abbr}", Video.on_air_v2
    )
  end
end
