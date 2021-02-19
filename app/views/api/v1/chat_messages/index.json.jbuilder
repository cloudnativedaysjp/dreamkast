json.array! @chat_messages do |msg|
  json.id msg.id
  json.body msg.body
  json.eventAbbr @conference.abbr
  json.talkId msg.talk_id
  json.boothId msg.booth_id
  json.createdAt msg.created_at.utc
end
