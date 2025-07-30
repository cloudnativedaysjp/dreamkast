FactoryBot.define do
  factory :sponsor_contact_invite do
    email { 'contact@example.com' }
    token { SecureRandom.hex(50) }
    expires_at { 1.day.from_now }
    conference
    sponsor
  end
end
