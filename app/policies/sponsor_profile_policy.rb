class SponsorProfilePolicy < ApplicationPolicy
  def edit?
    speaker.present? && record.id == speaker.id
  end

  def update?
    record.id == speaker.id
  end
end
