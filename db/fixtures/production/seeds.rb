if ENV['REVIEW_APP'] == 'true'
  csv = CSV.read(File.join(Rails.root, 'db/talks.csv'), headers: true)
  Talk.seed(csv.map(&:to_hash))

  csv = CSV.read(File.join(Rails.root, 'db/speakers.csv'), headers: true)
  Speaker.seed(csv.map(&:to_hash))

  csv = CSV.read(File.join(Rails.root, 'db/talks_speakers.csv'), headers: true)
  TalksSpeaker.seed(csv.map(&:to_hash))
end
