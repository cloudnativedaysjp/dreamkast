FactoryBot.define do
  factory :message_from_alice, class: ChatMessage do
    id { 1 }
    body { 'chat message 1' }
    conference_id { 1 }
    room_id { 1 }
    room_type { 'talk' }
    message_type { 0 }
    profile_id { 1 }
  end

  factory :message_from_bob, class: ChatMessage do
    id { 2 }
    body { 'chat message 2' }
    conference_id { 1 }
    room_id { 1 }
    room_type { 'talk' }
    message_type { 0 }
    profile_id { 3 }
  end
end
