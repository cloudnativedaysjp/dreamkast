class ApplicationPolicy
  attr_reader :speaker, :record

  def initialize(speaker, record)
    @speaker = speaker
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :speaker, :scope

    def initialize(speaker, scope)
      @speaker = speaker
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
