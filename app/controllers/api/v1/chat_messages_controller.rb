class Api::V1::ChatMessagesController < ApplicationController
  include SecuredApi
  before_action :set_profile

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
    message_type = @params[:messageType]

    attr = {profile_id: @profile.id, body: body, conference_id: conference.id, room_id: room_id, room_type: room_type, message_type: message_type}

    speaker = Speaker.find_by(conference: @conference.id, email: @current_user[:info][:email])
    attr[:speaker_id] = speaker.id if speaker.present?

    if reply_to
      parent = ChatMessage.find(reply_to)
      parent.children.create!(attr)
    else
      ChatMessage.create!(attr)
    end
  end

  def update
    @params ||= JSON.parse(request.body.read, {:symbolize_names => true})
    chat_msg = ChatMessage.find(params[:id])
    body= @params[:body]
    chat_msg.update!({body: body})
  end

  def event_name
    params[:eventAbbr]
  end
end
