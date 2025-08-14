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
    # Handle case where we're adding an exclusive attribute to a talk with other attributes
    if session_attribute&.is_exclusive?
      other_attributes = if persisted?
                           talk.talk_session_attributes.where.not(id:)
                         else
                           talk.talk_session_attributes
                         end

      if other_attributes.exists?
        errors.add(:session_attribute, "#{session_attribute.display_name} is exclusive and cannot coexist with other attributes")
      end
    end

    # Handle case where we're adding a non-exclusive attribute to a talk with exclusive attributes
    unless session_attribute&.is_exclusive?
      exclusive_attributes = if persisted?
                               talk.talk_session_attributes.joins(:session_attribute)
                                   .where(session_attributes: { is_exclusive: true })
                                   .where.not(id:)
                             else
                               talk.talk_session_attributes.joins(:session_attribute)
                                   .where(session_attributes: { is_exclusive: true })
                             end

      if exclusive_attributes.exists?
        exclusive_attr = exclusive_attributes.first.session_attribute
        errors.add(:session_attribute, "#{exclusive_attr.display_name} is exclusive and cannot coexist with other attributes")
      end
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
