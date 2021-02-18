class Api::V1::ChatMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @conference = Conference.find_by(abbr: params[:eventAbbr])
    query = {conference_id: @conference.id, room_type: params[:roomType], room_id: params[:roomId]}
    query[:created_at] = params[:createdFrom] if params[:createdFrom]
    query[:reply_to] = params[:replyTo] if params[:replyTo]
    @chat_messages = ChatMessage.where(query)
    render 'api/v1/chat_messages/index.json.jbuilder'
  end

  def create
    @params ||= JSON.parse(request.body.read, {:symbolize_names => true})
    conference = Conference.find_by(abbr: params[:eventAbbr])
    room_id = @params[:roomId]
    room_type = @params[:roomType]
    body= @params[:body]
    reply_to = @params[:replyTo]
    if reply_to
      parent = ChatMessage.find(reply_to)
      parent.children.create!(body: body, conference_id: conference.id, room_id: room_id, room_type: room_type)
    else
      ChatMessage.create!(body: body, conference_id: conference.id, room_id: room_id, room_type: room_type)
    end
  end
end
