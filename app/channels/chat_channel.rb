class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_channel"
    ChatMessage.all.each do |msg|
      ActionCable.server.broadcast 'chat_channel', {id: msg.id, body: msg.body}
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def post(data)
    ChatMessage.create!(body: data['body'], conference_id: 1)
  end
end
