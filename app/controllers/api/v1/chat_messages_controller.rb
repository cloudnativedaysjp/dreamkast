class Api::V1::ChatMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    conference_id = params[:eventId]
    talk_id = params[:talkId]
    created_from = params[:createdFrom]
    conference = Conference.find(conference_id)
    @chat_messages = ChatMessage.where(conference_id: conference.id, talk_id: talk_id, created_at: DateTime.parse(created_from)...)
    render 'api/v1/chat_messages/index.json.jbuilder'
  end

  def create
    @params ||= JSON.parse(request.body.read, {:symbolize_names => true})
    event_id = @params[:eventId]
    talk_id = @params[:talkId]
    body= @params[:body]
    ChatMessage.create!(body: body, conference_id: event_id, talk_id: talk_id)
  end
end
