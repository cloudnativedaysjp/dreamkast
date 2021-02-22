class ChatMessage < ApplicationRecord
  acts_as_nested_set

  after_create_commit { ChatMessageBroadcastJob.perform_later self }

  enum message_type: { chat: 0, qa: 1 }
end