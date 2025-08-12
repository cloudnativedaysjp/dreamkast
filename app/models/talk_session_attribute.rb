class TalkSessionAttribute < ApplicationRecord
  # Associations
  belongs_to :talk
  belongs_to :session_attribute
  
  # Validations
  validates :talk_id, uniqueness: { scope: :session_attribute_id, message: 'already has this session attribute assigned' }
  validate :exclusive_attribute_check
  
  # Callbacks
  after_create :sync_legacy_fields
  after_destroy :sync_legacy_fields
  
  private
  
  def exclusive_attribute_check
    return unless session_attribute&.is_exclusive?
    
    # Check if other attributes exist for this talk
    other_attributes = talk.talk_session_attributes
                          .where.not(id: id)
    
    if other_attributes.exists?
      errors.add(:session_attribute, "#{session_attribute.display_name} is exclusive and cannot coexist with other attributes")
    end
  end
  
  def sync_legacy_fields
    # Sync with existing abstract field for intermission (for backward compatibility)
    if session_attribute.name == 'intermission'
      if destroyed?
        talk.update_column(:abstract, nil) if talk.abstract == 'intermission'
      else
        talk.update_column(:abstract, 'intermission') unless talk.abstract == 'intermission'
      end
    end
  end
end