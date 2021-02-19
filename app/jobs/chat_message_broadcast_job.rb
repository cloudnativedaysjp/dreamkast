class ChatMessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(*args)
    msg = args[0]
    ActionCable.server.broadcast 'chat_channel', {id: msg.id, body: msg.body}
  end
end
