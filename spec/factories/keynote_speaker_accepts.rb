FactoryBot.define do
  factory :keynote_speaker_accept do
    keynote_speaker_invitation
    speaker
    talk
  end
end
