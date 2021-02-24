json.array! @tracks do |track|
  json.id track.id
  json.name track.name
  json.videoPlatform track.video_platform
  json.videoId track.video_id
end
