FactoryBot.define do
  factory :sponsor_contact_invite_accept do
    conference
    sponsor
    sponsor_contact
    sponsor_contact_invite
  end
end
