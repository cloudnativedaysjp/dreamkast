class ChatMessageBroadcastJob < ApplicationJob
  queue_as :fifo
  self.queue_adapter = :amazon_sqs

  def perform(*args)
    msg = args[0]
    channel_name = "chat_channel_#{msg.room_type}#{msg.room_id}"
    ActionCable.server.broadcast(channel_name, {
                                   id: msg.id,
      profileId: msg.profile_id,
      speakerId: msg.speaker_id,
      body: msg.body,
      roomType: msg.room_type,
      roomId: msg.room_id,
      createdAt: msg.created_at.utc,
      replyTo: msg.parent_id,
      messageType: msg.message_type
                                 })
  end
end
