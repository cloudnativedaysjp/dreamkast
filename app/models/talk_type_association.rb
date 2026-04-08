class TalkTypeAssociation < ApplicationRecord
  # Associations
  belongs_to :talk
  belongs_to :talk_type

  # Validations
  validates :talk_id, uniqueness: { scope: :talk_type_id, message: 'already has this type assigned' }
  validate :exclusive_attribute_check

  # Callbacks
  after_create :sync_legacy_fields
  after_destroy :sync_legacy_fields

  private

  def exclusive_attribute_check
    # Handle case where we're adding an exclusive type to a talk with other types
    if talk_type&.is_exclusive?
      other_types = if persisted?
                      talk.talk_type_associations.where.not(id:)
                    else
                      talk.talk_type_associations
                    end

      if other_types.exists?
        errors.add(:talk_type, "#{talk_type.display_name} is exclusive and cannot coexist with other types")
      end
    end

    # Handle case where we're adding a non-exclusive type to a talk with exclusive types
    unless talk_type&.is_exclusive?
      exclusive_types = if persisted?
                          talk.talk_type_associations.joins(:talk_type)
                              .where(talk_types: { is_exclusive: true })
                              .where.not(id:)
                        else
                          talk.talk_type_associations.joins(:talk_type)
                              .where(talk_types: { is_exclusive: true })
                        end

      if exclusive_types.exists?
        exclusive_type = exclusive_types.first.talk_type
        errors.add(:talk_type, "#{exclusive_type.display_name} is exclusive and cannot coexist with other types")
      end
    end
  end

  def sync_legacy_fields
    # Sync with existing abstract field for intermission (for backward compatibility)
    if talk_type.id == TalkType::INTERMISSION_ID
      if destroyed?
        talk.update_column(:abstract, nil) if talk.abstract == 'intermission'
      else
        talk.update_column(:abstract, 'intermission') unless talk.abstract == 'intermission'
      end
    end
  end
end
