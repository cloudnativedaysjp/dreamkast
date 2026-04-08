class ChatMessage < ApplicationRecord
  acts_as_nested_set

  after_create_commit { ChatMessageBroadcastJob.perform_later(self) }
  after_update_commit { ChatMessageBroadcastJob.perform_later(self) }

  belongs_to :profile, optional: true

  enum :message_type, { chat: 0, qa: 1 }

  validates :body, presence: true, length: { maximum: 512 }

  def self.counts
    ChatMessage.all.select(
      [:conference_id, :room_id, ChatMessage.arel_table[:room_id].count.as('count')]
    ).where(conference_id: Conference.opened.ids).group(:conference_id, :room_id)
  end

  def child_messages
    ChatMessage.where(parent_id: id)
  end
end
