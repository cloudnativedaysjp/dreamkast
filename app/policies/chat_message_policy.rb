class ChatMessagePolicy < ApplicationPolicy
  def update?
    speaker.present? && record.profile_id == speaker.id
  end
end
