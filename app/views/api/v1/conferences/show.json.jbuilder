json.id @conference.id
json.name @conference.name
json.abbr @conference.abbr
json.status @conference.status
json.theme @conference.theme
json.about @conference.about
json.privacy_policy @conference.privacy_policy
json.privacy_policy_for_speaker @conference.privacy_policy_for_speaker
json.copyright @conference.copyright
json.ccc @conference.coc
json.conferenceDays @conference.conference_days.map{|day| { id: day.id, date: day.date}}.sort{|a, b| a[:date] <=> b[:date]}
