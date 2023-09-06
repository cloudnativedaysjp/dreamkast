json.array!(@streamings) do |streaming|
  json.id(streaming.id)
  json.status(streaming.status)
  json.destination_url(streaming.destination_url)
  json.playback_url(streaming.playback_url)
end
