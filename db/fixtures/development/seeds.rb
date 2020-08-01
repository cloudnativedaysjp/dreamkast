csv = CSV.read(File.join(Rails.root, 'db/talks.csv'), headers: true)
Talk.seed(
  csv.map(&:to_hash)
)

csv = CSV.read(File.join(Rails.root, 'db/speakers.csv'), headers: true)
Speaker.seed(
  csv.map(&:to_hash)
)

csv = CSV.read(File.join(Rails.root, 'db/talks_speakers.csv'), headers: true)
TalksSpeaker.seed(
  csv.map(&:to_hash)
)

Profile.seed(
  {
    id: 1,
    first_name: "夢見",
    last_name: "太郎",
    industry_id: 1,
    sub: "a",
    occupation: "a",
    department: "a",
    email: "xxx@example.com",
    company_name: "aaa",
    company_address: "xxx",
    company_email: "yyy@example.com",
    company_tel: "123-456-7890",
    position: "president"
  }
)

RegisteredTalk.seed(
  { talk_id: 1, profile_id: 1},
  { talk_id: 7, profile_id: 1},
  { talk_id: 14, profile_id: 1},
  { talk_id: 21, profile_id: 1},
  { talk_id: 28, profile_id: 1},
  { talk_id: 35, profile_id: 1},
  { talk_id: 42, profile_id: 1}
)
