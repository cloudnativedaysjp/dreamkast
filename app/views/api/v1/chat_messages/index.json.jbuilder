json.array! @chat_messages do |msg|
  json.id msg.id
  json.profile_id msg.profile_id
  json.speaker_id msg.speaker_id
  json.body msg.body
  json.eventAbbr @conference.abbr
  json.roomType msg.room_type
  json.roomId msg.room_id
  json.createdAt msg.created_at.utc
  json.replyTo msg.parent_id
  json.messageType msg.message_type
end
