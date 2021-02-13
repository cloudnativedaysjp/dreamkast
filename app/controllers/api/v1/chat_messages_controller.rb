class Api::V1::ChatMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @conference = Conference.find_by(params[:eventAbbr])
    talk_id = params[:talkId]
    created_from = params[:createdFrom]
    @chat_messages = ChatMessage.where(conference_id: @conference.id, talk_id: talk_id)
    if created_from
      @chat_messages = @chat_messages.where(created_at: DateTime.parse(created_from)...)
    end
    render 'api/v1/chat_messages/index.json.jbuilder'
  end

  def create
    @params ||= JSON.parse(request.body.read, {:symbolize_names => true})
    conference = Conference.find_by(params[:eventAbbr])
    talk_id = @params[:talkId]
    body= @params[:body]
    ChatMessage.create!(body: body, conference_id: conference.id, talk_id: talk_id)
  end
end
