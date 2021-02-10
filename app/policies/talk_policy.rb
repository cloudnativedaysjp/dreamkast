class TalkPolicy < ApplicationPolicy
  def new?
    record.speakers.map(&:id).include?(speaker.id)
  end

  def create?
    record.speakers.map(&:id).include?(speaker.id)
  end

  def edit?
    record.speakers.map(&:id).include?(speaker.id)
  end

  def update?
    record.speakers.map(&:id).include?(speaker.id)
  end

  def destroy?
    record.speakers.map(&:id).include?(speaker.id)
  end
end
