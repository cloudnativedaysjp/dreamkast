json.array! @ivss do |ivs|
  json.channel ivs.params.dig('channel')
  json.stream_key ivs.params.dig('stream_key')
end
