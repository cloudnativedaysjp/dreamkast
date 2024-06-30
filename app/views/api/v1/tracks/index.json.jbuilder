json.array!(@tracks) do |track|
  json.id(track.id)
  json.name(track.name)
  json.videoPlatform(track.video_platform)
  json.videoId(track.streaming.present? ? track.streaming&.playback_url : track.video_id)
  json.onAirTalk(track.on_air_talk)
end
