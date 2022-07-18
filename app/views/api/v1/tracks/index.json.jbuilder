json.array!(@tracks) do |track|
  json.id(track.id)
  json.name(track.name)
  json.videoPlatform(track.video_platform)
  json.videoId(track.live_stream_ivs.present? ? track.live_stream_ivs&.playback_url : track.video_id)
  json.channelArn(track.live_stream_ivs&.channel_arn)
  json.onAirTalk(track.on_air_talk)
end
