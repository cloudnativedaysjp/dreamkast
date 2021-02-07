class ChatMessage < ApplicationRecord
  acts_as_nested_set

  after_create_commit { ChatMessageBroadcastJob.perform_later self }
end