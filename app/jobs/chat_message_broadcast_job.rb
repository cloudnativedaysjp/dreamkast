class ChatMessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(*args)
    msg = args[0]
    channel_name = "chat_channel_#{msg.room_type}#{msg.room_id}"
    ActionCable.server.broadcast channel_name, {id: msg.id, body: msg.body, roomType: msg.room_type, roomId: msg.room_id}
  end
end
