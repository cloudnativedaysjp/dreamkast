class SpeakerPolicy < ApplicationPolicy
  def show?
    record.id == speaker.id
  end

  def edit?
    record.id == speaker.id
  end

  def update?
    record.id == speaker.id
  end

  def destroy?
    record.id == speaker.id
  end
end