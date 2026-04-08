FactoryBot.define do
  factory :speaker_invitation do
    email { 'MyString' }
    token { 'MyString' }
    talk { nil }
    conference { nil }
    expires_at { '2024-09-05 20:27:25' }
  end
end
