class SpeakerPolicy < ApplicationPolicy
  def new?
    record.id == speaker.id
  end

  def create?
    record.id == speaker.id
  end

  def show?
    record.id == speaker.id
  end

  def edit?
    speaker.present? && record.id == speaker.id
  end

  def update?
    record.id == speaker.id
  end

  def destroy?
    record.id == speaker.id
  end
end
