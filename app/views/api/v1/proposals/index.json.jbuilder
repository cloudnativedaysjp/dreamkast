json.array!(@proposals) do |proposal|
  json.id(proposal.id)
  json.conferenceId(proposal.conference_id)
  json.talkId(proposal.talk_id)
  json.status(proposal.status_message)
end
