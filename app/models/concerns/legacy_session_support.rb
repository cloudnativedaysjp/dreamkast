module LegacySessionSupport
  extend ActiveSupport::Concern

  included do
    # Extended scopes that include both new and legacy data
    scope :all_sponsors, lambda {
      left_joins(:session_attributes)
        .where(session_attributes: { name: 'sponsor' })
        .or(where.not(sponsor_id: nil))
        .distinct
    }

    scope :all_intermissions, lambda {
      left_joins(:session_attributes)
        .where(session_attributes: { name: 'intermission' })
        .or(where(abstract: 'intermission'))
        .distinct
    }

    scope :all_keynotes, lambda {
      left_joins(:session_attributes)
        .where(session_attributes: { name: 'keynote' })
        .distinct
    }
  end

  # Override methods are already defined in Talk model with backward compatibility
  # sponsor_session? checks both session_attributes and sponsor_id
  # intermission? checks both session_attributes and abstract='intermission'
end
