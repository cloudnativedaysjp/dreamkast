json.id(@profile.id)
json.email(@profile.email)
json.name("#{@profile.last_name} #{@profile.first_name}")
json.isAttendOffline(@profile.attend_offline?)
json.registeredTalks(@profile.registered_talks.includes([talk: [:speakers, :conference_day, { track: :room }]]).map do |registered_talk|
  {
    talkId: registered_talk.talk.id,
    talkTitle: registered_talk.talk.title,
    talkSpeakers: registered_talk.talk.speakers.map { |speaker| { name: speaker.name, twitterId: speaker.twitter_id } },
    talkStartTime: registered_talk.talk.start_time.rfc3339,
    talkEndTime: registered_talk.talk.end_time.rfc3339,
    trackName: registered_talk.talk.track.name,
    roomName: registered_talk.talk.track.room.name,
    conferenceDay: registered_talk.talk.conference_day.date
  }
end)
