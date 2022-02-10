# == Schema Information
#
# Table name: chat_messages
#
#  id             :bigint           not null, primary key
#  body           :string(255)
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
class ChatMessage < ApplicationRecord
  acts_as_nested_set

  after_create_commit { ChatMessageBroadcastJob.perform_later(self) }
  after_update_commit { ChatMessageBroadcastJob.perform_later(self) }

  belongs_to :profile

  enum message_type: { chat: 0, qa: 1 }

  def counts
    ChatMessage.all.select(
      [:conference_id, :room_id, ChatMessage.arel_table[:room_id].count.as('count')]
    ).where(conference_id: Conference.opened.ids).group(:conference_id, :room_id)
  end
end
