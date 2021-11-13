json.array!(@ivss) do |ivs|
  json.track(ivs.track.name)
  json.rtmps_url("rtmps://#{ivs.params.dig('channel', 'ingest_endpoint')}:443/app/#{ivs.params.dig('stream_key', 'value')}")
  json.channel(ivs.params.dig("channel"))
  json.stream_key(ivs.params.dig("stream_key"))
end
