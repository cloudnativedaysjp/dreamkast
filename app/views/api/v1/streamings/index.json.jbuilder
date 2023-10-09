json.array!(@streamings) do |streaming|
  json.id(streaming.id)
  json.status(streaming.status)
  json.trackId(streaming.track.id)
  json.destinationUrl(streaming.destination_url || '')
  json.playbackUrl(streaming.playback_url || '')
  json.mediaLiveChannelStatus(streaming.media_live_channel&.state || '')
end
