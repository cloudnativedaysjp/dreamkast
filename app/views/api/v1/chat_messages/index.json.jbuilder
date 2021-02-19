json.array! @chat_messages do |msg|
  json.id msg.id
  json.body msg.body
  json.eventAbbr @conference.abbr
  json.roomType msg.room_type
  json.roomId msg.room_id
  json.createdAt msg.created_at.utc
  json.replyTo msg.parent_id
end
