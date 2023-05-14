json.array!(@proposals) do |proposal|
  json.id(proposal.id)
  json.conferenceId(proposal.conference_id)
  json.talkId(proposal.talk_id)
  json.title(proposal.talk.title)
  json.status(proposal.status_message)
  json.abstract(proposal.talk.abstract)
  json.speakers(proposal.talk.speakers.map { |speaker| { id: speaker.id, name: speaker.name } })
  json.params do
    json.talk_difficulty(proposal.talk.talk_difficulty&.name)
    proposal.talk.proposal_items.map do |item|
      json.set!(item.label, item.proposal_item_configs.first&.params)
    end
  end
end
