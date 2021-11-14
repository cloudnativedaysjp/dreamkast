json.array!(@tracks) do |track|
  json.id(track.id)
  json.name(track.name)
  json.videoPlatform(track.video_platform)
  json.videoId(@conference.abbr == "cndt2021" ? track.live_stream_ivs&.playback_url : track.video_id)
end
