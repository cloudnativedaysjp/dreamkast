class SessionAttributeService
  class ValidationError < StandardError; end
  
  def self.assign_attributes(talk, attribute_ids)
    new(talk).assign_attributes(attribute_ids)
  end
  
  def initialize(talk)
    @talk = talk
  end
  
  def assign_attributes(attribute_ids)
    attribute_ids = Array(attribute_ids).compact.reject(&:blank?)
    validate_attribute_assignments!(attribute_ids)
    
    ActiveRecord::Base.transaction do
      # Clear existing attributes
      @talk.talk_session_attributes.destroy_all
      
      # Add new attributes
      attribute_ids.each do |attr_id|
        attribute = SessionAttribute.find(attr_id)
        @talk.talk_session_attributes.create!(session_attribute: attribute)
      end
    end
    
    @talk.reload
  end
  
  private
  
  def validate_attribute_assignments!(attribute_ids)
    return if attribute_ids.empty?
    
    # Check if attributes exist
    existing_ids = SessionAttribute.where(id: attribute_ids).pluck(:id)
    missing_ids = attribute_ids.map(&:to_i) - existing_ids
    
    if missing_ids.any?
      raise ValidationError, "Unknown attribute IDs: #{missing_ids.join(', ')}"
    end
    
    # Check exclusive attribute constraints
    attributes = SessionAttribute.where(id: attribute_ids)
    exclusive_attributes = attributes.select(&:is_exclusive?)
    
    if exclusive_attributes.count > 1
      exclusive_names = exclusive_attributes.map(&:display_name)
      raise ValidationError, "Multiple exclusive attributes: #{exclusive_names.join(', ')}"
    end
    
    if exclusive_attributes.any? && attributes.count > 1
      raise ValidationError, "Exclusive attribute cannot coexist with others"
    end
  end
end