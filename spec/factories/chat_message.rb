FactoryBot.define do
  sequence :body do |i|
    "chat message #{i}"
  end

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

  factory :messages, class: ChatMessage do
    body { generate :body }
    conference_id { 1 }
    room_id { 1 }
    room_type { 'talk' }
    message_type { 0 }
    profile_id { 1 }

    trait :roomid1 do
      room_id { 1 }
    end

    trait :roomid2 do
      room_id { 2 }
    end

    trait :alice do
      profile_id { 1 }
    end

    trait :bob do
      profile_id { 3 }
    end
  end
end
