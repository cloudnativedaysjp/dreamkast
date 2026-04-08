FactoryBot.define do
  factory :sponsor_speaker_invite_accept do
    conference
    sponsor
    sponsor_contact
    speaker
    sponsor_speaker_invite
  end
end
