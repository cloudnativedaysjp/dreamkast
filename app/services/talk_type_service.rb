class TalkTypeService
  class ValidationError < StandardError; end

  def self.assign_types(talk, type_ids)
    new(talk).assign_types(type_ids)
  end

  def initialize(talk)
    @talk = talk
  end

  def assign_types(type_ids)
    type_ids = Array(type_ids).compact.reject(&:blank?).uniq.map(&:to_i)
    validate_type_assignments!(type_ids)

    ActiveRecord::Base.transaction do
      # Clear existing types
      @talk.talk_type_associations.destroy_all

      # Add new types (using uniq to avoid duplicates)
      type_ids.uniq.each do |type_id|
        type = TalkType.find(type_id)
        @talk.talk_type_associations.create!(talk_type: type)
      end
    end

    @talk.reload
  end

  private

  def validate_type_assignments!(type_ids)
    return if type_ids.empty?

    # Check if types exist
    existing_ids = TalkType.where(id: type_ids).pluck(:id)
    missing_ids = type_ids.map(&:to_i) - existing_ids

    if missing_ids.any?
      raise(ValidationError, "Unknown type IDs: #{missing_ids.join(', ')}")
    end

    # Check exclusive type constraints
    types = TalkType.where(id: type_ids)
    exclusive_types = types.select(&:is_exclusive?)

    if exclusive_types.count > 1
      exclusive_names = exclusive_types.map(&:display_name)
      raise(ValidationError, "Multiple exclusive types: #{exclusive_names.join(', ')}")
    end

    if exclusive_types.any? && types.count > 1
      raise(ValidationError, 'Exclusive type cannot coexist with others')
    end
  end
end
