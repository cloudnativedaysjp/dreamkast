json.array! @chat_messages do |msg|
  json.id msg.id
  json.profileId msg.profile_id
  json.speakerId msg.speaker_id
  json.body msg.body
  json.eventAbbr @conference.abbr
  json.roomType msg.room_type
  json.roomId msg.room_id
  json.createdAt msg.created_at.utc
  json.replyTo msg.parent_id
  json.messageType msg.message_type
end
