class ChatMessagePolicy < ApplicationPolicy
  def update?
    record.profile_id == speaker.id
  end
end
