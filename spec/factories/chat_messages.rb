# == Schema Information
#
# Table name: chat_messages
#
#  id             :bigint           not null, primary key
#  body           :text(65535)
#  children_count :integer          default(0), not null
#  depth          :integer          default(0), not null
#  lft            :integer          not null
#  message_type   :integer
#  rgt            :integer          not null
#  room_type      :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  conference_id  :bigint           not null
#  parent_id      :integer
#  profile_id     :bigint
#  room_id        :bigint
#  speaker_id     :bigint
#
# Indexes
#
#  index_chat_messages_on_conference_id  (conference_id)
#  index_chat_messages_on_lft            (lft)
#  index_chat_messages_on_parent_id      (parent_id)
#  index_chat_messages_on_profile_id     (profile_id)
#  index_chat_messages_on_rgt            (rgt)
#  index_chat_messages_on_speaker_id     (speaker_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (speaker_id => speakers.id)
#
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

    trait :qa do
      message_type { 'qa' }
    end
  end
end
