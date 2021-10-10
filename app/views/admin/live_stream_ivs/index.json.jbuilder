json.tracks do
  json.array! @ivss_for_tracks do |ivs|
    json.track ivs.track.name
    json.channel ivs.params.dig('channel')
    json.stream_key ivs.params.dig('stream_key')
  end
end

json.talks do
  json.array! @ivss_for_talks do |ivs|
    json.talk_id ivs.talk.id
    json.talk_date ivs.talk.conference_day.date
    json.talk_start_time ivs.talk.start_time.strftime("%H:%M")
    json.talk_end_time ivs.talk.end_time.strftime("%H:%M")
    json.track_name ivs.talk.track_name
    json.channel ivs.params.dig('channel')
    json.stream_key ivs.params.dig('stream_key')
  end
end