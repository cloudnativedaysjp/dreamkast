class QaChannel < ApplicationCable::Channel
  def subscribed
    talk_id = params[:talk_id]

    unless talk_id.present?
      reject
      return
    end

    begin
      talk = Talk.find(talk_id)
      # トークが存在し、有効なカンファレンスに属していることを確認
      unless talk&.conference_id.present?
        reject
        return
      end

      stream_from "qa_talk_#{talk.id}"
    rescue ActiveRecord::RecordNotFound
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
