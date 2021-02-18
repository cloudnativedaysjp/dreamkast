class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_channel_#{params["roomType"]}#{params["roomId"]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def post(data)
    ChatMessage.create!(body: data['body'], conference_id: 1)
  end
end
