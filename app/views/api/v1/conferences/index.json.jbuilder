json.array!(@conferences) do |conference|
  json.id(conference.id)
  json.name(conference.name)
  json.abbr(conference.abbr)
  json.status(conference.conference_status)
  json.rehearsalMode(conference.rehearsal_mode)
  json.theme(conference.theme)
  json.about(conference.about)
  json.privacy_policy(conference.privacy_policy)
  json.privacy_policy_for_speaker(conference.privacy_policy_for_speaker)
  json.copyright(conference.copyright)
  json.coc(conference.coc)
  json.conferenceDays(conference.conference_days.map { |day| { id: day.id, date: day.date, internal: day.internal } }.sort { |a, b| a[:date] <=> b[:date] })
end
