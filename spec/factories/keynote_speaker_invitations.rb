FactoryBot.define do
  factory :keynote_speaker_invitation do
    conference
    email { 'alice@example.com' }
    name { 'alice' }
    token { SecureRandom.hex(32) }
    invited_at { Time.current }
    expires_at { 7.days.from_now }

    trait :accepted do
      accepted_at { Time.current }
      after(:create) do |invitation|
        speaker = create(:speaker_alice, conference: invitation.conference)
        talk = create(:talk1, conference: invitation.conference)
        create(:keynote_speaker_accept, keynote_speaker_invitation: invitation, speaker:, talk:)
      end
    end

    trait :expired do
      invited_at { 8.days.ago }
      expires_at { 1.day.ago }
    end
  end
end
