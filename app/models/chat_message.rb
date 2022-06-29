# == Schema Information
#
# Table name: chat_messages
#
#  id             :integer          not null, primary key
#  conference_id  :integer          not null
#  profile_id     :integer
#  speaker_id     :integer
#  body           :string(255)
#  parent_id      :integer
#  lft            :integer          not null
#  rgt            :integer          not null
#  depth          :integer          default("0"), not null
#  children_count :integer          default("0"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  room_type      :string(255)
#  room_id        :integer
#  message_type   :integer
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

class ChatMessage < ApplicationRecord
  acts_as_nested_set

  after_create_commit { ChatMessageBroadcastJob.perform_later(self) }
  after_update_commit { ChatMessageBroadcastJob.perform_later(self) }

  belongs_to :profile, optional: true

  enum message_type: { chat: 0, qa: 1 }

  def self.counts
    ChatMessage.all.select(
      [:conference_id, :room_id, ChatMessage.arel_table[:room_id].count.as('count')]
    ).where(conference_id: Conference.opened.ids).group(:conference_id, :room_id)
  end
end
