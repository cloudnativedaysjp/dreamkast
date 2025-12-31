class QaChannel < ApplicationCable::Channel
  def subscribed
    talk = Talk.find(params[:talk_id])
    stream_from "qa_talk_#{talk.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
