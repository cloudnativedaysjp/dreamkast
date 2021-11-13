json.id(@track.id)
json.name(@track.name)
json.videoPlatform(@track.on_air_talk.present? ? @track.on_air_talk.site : "")
json.videoId(@track.on_air_talk.present? ? @track.on_air_talk.video_id : "")
