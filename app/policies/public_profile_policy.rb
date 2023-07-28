class PublicProfilePolicy < ApplicationPolicy
  attr_reader :profile
  attr_reader :record

  def initialize(profile, record)
    @profile = profile
    @record = record
  end

  def new?
    record.profile_id == profile.id
  end

  def create?
    record.profile_id == profile.id
  end

  def show?
    false
  end

  def edit?
    profile.present? && record.profile_id == profile.id
  end

  def update?
    record.profile_id == profile.id
  end

  def destroy?
    record.profile_id == profile.id
  end
end
