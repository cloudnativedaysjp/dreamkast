FactoryBot.define do
  factory :sponsor_speaker_invite do
    email { 'speaker@example.com' }
    token { SecureRandom.hex(50) }
    expires_at { 1.day.from_now }
    conference
    sponsor
  end
end
